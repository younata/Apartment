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
                self.sendWatchLoginCredentials()
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
                self.sendWatchLoginCredentials()
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
        if let session = self.watchSession {
            self.watchDelegate.session(session, didReceiveApplicationContext: session.receivedApplicationContext)
        }
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
            self.updateWatchSession()
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

        self.updateWatchSession()

        for object in self.subscribers.allObjects {
            guard let subscriber = object as? HomeRepositorySubscriber else { continue }
            subscriber.didUpdateStates(self._states)
        }
    }

    private func updateWatchSession() {
        let states = self._states.map { $0.jsonObject }
        let services = self._services.map { ["domain": $0.domain, "services": $0.services] }
        let message = ["states": states, "services": services]
        self.watchSession?.transferUserInfo(message)
    }

    private func sendWatchLoginCredentials() {
        guard self.configured else { return }
        do {
            try self.watchSession?.updateApplicationContext(["backendURL": self._backendURL!.absoluteString, "backendPassword": self.backendPassword])
        } catch let error as NSError {
            print("Error sending watch credentials: \(error)")
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
        if let urlString = applicationContext["backendURL"] as? String {
            self.homeRepository?.backendURL = NSURL(string: urlString)
        }
        if let password = applicationContext["backendPassword"] as? String {
            self.homeRepository?.backendPassword = password
        }
    }

    @objc private func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        let states: [State]
        let services: [Service]
        if let statesJson = userInfo["states"] as? [[String: AnyObject]] {
            states = statesJson.reduce(Array<State>()) {
                if let state = State.NewFromJSON($1) {
                    return $0 + [state]
                }
                return $0
            }
        } else { states = [] }
        if let servicesJson = userInfo["services"] as? [[String: AnyObject]] {
            services = servicesJson.reduce(Array<Service>()) {
                if let name = $1["domain"] as? String,
                    services = $1["services"] as? [String] {
                        return $0 + [Service(domain: name, services: services)]
                }
                return $0
            }
        } else { services = [] }
        self.didUpdateData?(states, services)
    }
}