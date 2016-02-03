import Foundation
import WatchConnectivity

public protocol HomeRepository {
    var backendURL: NSURL! { get set }
    var backendPassword: String! { get set }

    func addSubscriber(subscriber: HomeRepositorySubscriber)

    func states(callback: [State] -> Void)
    func services(callback: [Service] -> Void)

    func updateService(service: Service, method: String, onEntity: State, callback: ([State], NSError?) -> Void)
}

public extension HomeRepository {
    var configured: Bool {
        return self.backendPassword != nil && self.backendURL != nil
    }
}

public protocol HomeRepositorySubscriber: NSObjectProtocol {
    func didUpdateStates(states: [State])
}

class HomeAssistantRepository: HomeRepository {
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
            self.homeService.baseURL = newValue.URLByAppendingPathComponent("api", isDirectory: true)
            self.breakCache()
        }
    }

    var backendPassword: String! {
        get {
            return self.homeService.apiKey
        }
        set {
            self.homeService.apiKey = newValue
            self.breakCache()
        }
    }

    private var _states = [State]()
    private var _services = [Service]()

    let watchSession = WCSession.defaultSession()
    private let watchDelegate = WatchConnectivityDelegate()

    let homeService: HomeAssistantService

    private let subscribers = NSHashTable.weakObjectsHashTable()

    init(homeService: HomeAssistantService) {
        self.homeService = homeService
        self.watchDelegate.didUpdateStates = {
            self.updateStates($0)
        }
        self.watchSession.delegate = self.watchDelegate
    }

    func addSubscriber(subscriber: HomeRepositorySubscriber) {
        self.subscribers.addObject(subscriber)
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
        self.homeService.callService(service.domain, onDomain: method, data: ["entity_id": state.entityId]) { states, error in
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
        self.watchSession.sendMessage(message, replyHandler: nil, errorHandler: nil)

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
    var didUpdateStates: (([State]) -> (Void))? = nil

    @objc private func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        if let statesJson = message["states"] as? [[String: AnyObject]] {
            let states = statesJson.reduce(Array<State>()) {
                if let state = State.NewFromJSON($1) {
                    return $0 + [state]
                }
                return $0
            }
            self.didUpdateStates?(states)
        }
    }
}