import Foundation
import WatchConnectivity

public protocol HomeRepository {
    var backendURL: NSURL! { get set }
    var backendPassword: String! { get set }

    func addSubscriber(subscriber: HomeRepositorySubscriber)

    func apiAvailable(callback: Bool -> Void)

    func states(callback: [State] -> Void)
    func services(callback: [Service] -> Void)

    func updateService(service: Service, method: String, onEntity: State, callback: ([State], NSError?) -> Void)
}

public extension HomeRepository {
    var configured: Bool {
        return self.backendPassword?.isEmpty == false && self.backendURL?.absoluteString.isEmpty == false
    }
}

public protocol HomeRepositorySubscriber: NSObjectProtocol {
    func didUpdateStates(states: [State])
}

class HomeAssistantRepository: HomeRepository {
    private var _backendURL: NSURL?
    var backendURL: NSURL! {
        get {
            let url = self.homeService.baseURL
            if url == nil {
                return nil
            }

            let port: Int
            if let portNumber = url.port {
                port = portNumber.integerValue
            } else if url.scheme == "https" {
                port = 443
            } else {
                port = 80
            }

            return NSURL(string: "\(url.scheme)://\(url.host!):\(port)")
        }
        set {
            if _backendURL == newValue {
                return
            }
            _backendURL = newValue
            self.homeService.baseURL = newValue.URLByAppendingPathComponent("api", isDirectory: true)
            if self.configured {
                self.breakCache()
            }
        }
    }

    var backendPassword: String! {
        get {
            return self.homeService.apiKey
        }
        set {
            if self.homeService.apiKey == newValue {
                return
            }
            self.homeService.apiKey = newValue

            if self.configured {
                self.breakCache()
            }
        }
    }

    private var _states = [State]()
    private var _services = [Service]()

    let watchSession: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.defaultSession()
        }
        return nil
    }()
    private let watchDelegate = WatchConnectivityDelegate()

    let homeService: HomeAssistantService

    private let subscribers = NSHashTable.weakObjectsHashTable()

    init(homeService: HomeAssistantService) {
        self.homeService = homeService
        self.watchDelegate.didUpdateData = {
            self.updateStates($0)
            self._services = $1
        }
        self.watchSession?.delegate = self.watchDelegate
        self.watchDelegate.homeRepository = self
        self.watchSession?.activateSession()
    }

    func addSubscriber(subscriber: HomeRepositorySubscriber) {
        self.subscribers.addObject(subscriber)
    }

    func apiAvailable(callback: Bool -> Void) {
        if !self.configured {
            callback(false)
        } else {
            self.homeService.apiAvailable(callback)
        }
    }

    func states(callback: [State] -> Void) {
        if !self._states.isEmpty {
            callback(self._states)
        }

        self.forceUpdateStates(callback)
    }

    func services(callback: [Service] -> Void) {
        if !self._services.isEmpty {
            callback(self._services)
        }

        self.homeService.services { services, error in
            if let _ = error {
                callback([])
                return
            }
            callback(services)
            self._services = services
        }
    }

    func updateService(service: Service, method: String, onEntity state: State, callback: ([State], NSError?) -> Void) {
        self.homeService.callService(service.domain, method: method, data: ["entity_id": state.entityId]) { states, error in
            callback(states, error)
            if error == nil {
                self.forceUpdateStates{ _ in }
            }
        }
    }

    private func forceUpdateStates(callback: [State] -> Void) {
        self.homeService.status {states, error in
            if let _ = error {
                callback([])
                return
            }
            self.updateStates(states)
            callback(self._states)
        }
    }

    private func updateStates(newStates: [State]) {
        self._states = newStates

        let message = ["states": newStates.map({ $0.jsonObject })]
        self.watchSession?.sendMessage(message, replyHandler: nil, errorHandler: nil)

        for object in self.subscribers.allObjects {
            guard let subscriber = object as? HomeRepositorySubscriber else { continue }
            subscriber.didUpdateStates(self._states)
        }
    }

    private func breakCache() {
        self._services = []
        self._states = []

        self.forceUpdateStates { _ in }
        self.services { _ in }
    }
}

private class WatchConnectivityDelegate: NSObject, WCSessionDelegate {
    var didUpdateData: (([State], [Service]) -> Void)?
    var homeRepository: HomeRepository?

    @objc private func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        let states: [State]
        let services: [Service]
        if let statesJson = applicationContext["states"] as? [[String: AnyObject]] {
            states = statesJson.reduce(Array<State>()) {
                if let state = State.NewFromJSON($1) {
                    return $0 + [state]
                }
                return $0
            }
        } else { states = [] }
        if let servicesJson = applicationContext["services"] as? [[String: AnyObject]] {
            services = servicesJson.reduce(Array<Service>()) {
                if let name = $1["domain"] as? String,
                    services = $1["services"] as? [String: AnyObject] {
                        return $0 + [Service(domain: name, services: Array(services.keys))]
                }
                return $0
            }
        } else { services = [] }
        self.didUpdateData?(states, services)
    }
}