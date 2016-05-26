import Foundation
import WatchConnectivity

public protocol HomeRepositorySubscriber: NSObjectProtocol {
    func didChangeLoginStatus(loggedIn: Bool)
}

public protocol HomeRepository: class {
    var backendURL: NSURL? { get set }
    var backendPassword: String? { get set }
    var watchGlanceEntityId: String? { get set }
    var watchComplicationEntityId: String? { get set }

    var subscribers: [HomeRepositorySubscriber] { get }

    func addSubscriber(subscriber: HomeRepositorySubscriber)

    func apiAvailable(callback: Bool -> Void)

    func configuration(callback: HomeConfiguration? -> Void)
    func history(entity: State?, callback: [State] -> Void)

    func states(callback: [State] -> Void)
    func services(callback: [Service] -> Void)

    func updateService(service: Service, method: String, onEntity: State, callback: ([State], NSError?) -> Void)
}

public extension HomeRepository {
    var loggedIn: Bool {
        return self.backendPassword?.isEmpty == false && self.backendURL?.absoluteString.isEmpty == false
    }

    func login(url url: NSURL, password: String, callback: Bool -> Void) {
        self.backendURL = url
        self.backendPassword = password

        self.apiAvailable {
            if $0 {
                for subscriber in self.subscribers {
                    subscriber.didChangeLoginStatus(self.loggedIn)
                }
            }
            callback($0)
        }
    }

    func logout() {
        let wasConfigured = self.loggedIn
        self.backendURL = nil
        self.backendPassword = nil
        guard wasConfigured else { return }
        for subscriber in self.subscribers {
            subscriber.didChangeLoginStatus(false)
        }
    }

    func watchGlanceEntity(callback: State? -> Void) {
        guard self.loggedIn else { callback(nil); return }
        guard let entityId = self.watchGlanceEntityId else { callback(nil); return }
        self.states {
            callback($0.filter { $0.entityId == entityId }.first)
        }
    }

    func watchComplicationEntity(callback: State? -> Void) {
        guard self.loggedIn else { callback(nil); return }
        guard let entityId = self.watchComplicationEntityId else { callback(nil); return }
        self.states {
            callback($0.filter { $0.entityId == entityId }.first)
        }
    }

    func groups(includeScenes includeScenes: Bool, callback: ([State], [Group]) -> Void) {
        guard self.loggedIn else { callback([], []); return }
        self.states { states in
            let groups = states.filter { $0.isGroup && $0.groupAutoCreated != true }
            var groupData = [(State, [State])]()
            for group in groups {
                if let entities = group.groupEntities {
                    let groupStates = states.filter({ entities.contains($0.entityId) && !$0.hidden }).sort({$0.displayName.lowercaseString < $1.displayName.lowercaseString})
                    groupData.append((group, groupStates))
                }
            }

            if includeScenes {
                let scenes = states.filter({ $0.isScene && !$0.hidden }).sort({ $0.displayName.lowercaseString < $1.displayName.lowercaseString })
                if !scenes.isEmpty {
                    let sceneGroup = State(attributes: ["friendly_name": "Scenes"], entityId: "group.scenes", lastChanged: NSDate(), lastUpdated: NSDate(), state: "")
                    groupData.insert((sceneGroup, scenes), atIndex: 0)
                }
            }

            callback(states, groupData.map { Group(data: $0) } )
        }
    }

    func serviceForEntity(entity: State, includeHomeAssistantService includeHomeAssisstant: Bool, callback: Service? -> Void) {
        self.services { services in
            if let service = services.filter({ $0.domain == entity.domain }).first {
                callback(service)
            }
            if includeHomeAssisstant {
                callback(services.filter({ $0.domain == "homeassistant" }).first)
            }
        }
    }
}

class HomeAssistantRepository: HomeRepository {
    private var _backendURL: NSURL?
    var backendURL: NSURL? {
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
            self.homeService.baseURL = newValue?.URLByAppendingPathComponent("api", isDirectory: true)
            if self.loggedIn {
                self.login()
            }
        }
    }

    var backendPassword: String? {
        get {
            return self.homeService.apiKey
        }
        set {
            if self.homeService.apiKey == newValue {
                return
            }
            self.homeService.apiKey = newValue

            if self.loggedIn {
                self.login()
            }
        }
    }

    var watchGlanceEntityId: String? {
        get {
            return self.userDefaults.stringForKey("WatchGlanceID")
        }
        set {
            self.userDefaults.setValue(newValue, forKey: "WatchGlanceID")
        }
    }

    var watchComplicationEntityId: String? {
        get {
            return self.userDefaults.stringForKey("WatchComplicationID")
        }
        set {
            self.userDefaults.setValue(newValue, forKey: "WatchComplicationID")
        }
    }

    private var _states = [State]()
    private var _services = [Service]()
    private var _configuration: HomeConfiguration?

    let watchSession: WCSession? = {
        if WCSession.isSupported() {
            return WCSession.defaultSession()
        }
        return nil
    }()
    private let watchDelegate = WatchConnectivityDelegate()

    private let homeService: HomeAssistantService
    private let userDefaults: NSUserDefaults

    init(homeService: HomeAssistantService, userDefaults: NSUserDefaults) {
        self.homeService = homeService
        self.userDefaults = userDefaults
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

    private let _subscribers = NSHashTable.weakObjectsHashTable()
    var subscribers: [HomeRepositorySubscriber] {
        return self._subscribers.allObjects.reduce([HomeRepositorySubscriber]()) {
            if let subscriber = $1 as? HomeRepositorySubscriber {
                return $0 + [subscriber]
            }
            return $0
        }
    }
    func addSubscriber(subscriber: HomeRepositorySubscriber) {
        self._subscribers.addObject(subscriber)
    }

    func apiAvailable(callback: Bool -> Void) {
        if !self.loggedIn {
            callback(false)
        } else {
            self.homeService.apiAvailable(callback)
        }
    }

    func configuration(callback: HomeConfiguration? -> Void) {
        guard self.loggedIn else { callback(nil); return }
        if let configuration = self._configuration {
            callback(configuration)
        }
        self.homeService.configuration { configuration, error in
            self._configuration = configuration
            callback(configuration)
        }
    }

    func history(entity: State?, callback: [State] -> Void) {
        guard self.loggedIn else { callback([]); return }
        self.homeService.history(NSDate(), state: entity) { states, error in
            callback(states ?? [])
        }
    }

    private var statesCallbacks: [([State] -> Void)] = []
    func states(callback: [State] -> Void) {
        guard self.loggedIn else { callback([]); return }

        self.statesCallbacks.append(callback)
        guard self.statesCallbacks.count == 1 else { return }
        self.forceUpdateStates()
    }

    private var serviceCallbacks: [([Service] -> Void)] = []
    func services(callback: [Service] -> Void) {
        guard self.loggedIn else { callback([]); return }
        if !self._services.isEmpty {
            callback(self._services)
        }

        self.serviceCallbacks.append(callback)
        guard self.serviceCallbacks.count == 1 else { return }
        self.homeService.services { services, error in
            if let _ = error {
                for callback in self.serviceCallbacks {
                    callback([])
                }
                return
            }
            self._services = services
            self.updateWatchSession()
            for callback in self.serviceCallbacks {
                callback(services)
            }
            self.serviceCallbacks = []
        }
    }

    func updateService(service: Service, method: String, onEntity state: State, callback: ([State], NSError?) -> Void) {
        guard self.loggedIn else { callback([], nil); return }
        self.homeService.callService(service.domain, method: method, data: ["entity_id": state.entityId]) { states, error in
            callback(states, error)
            if error == nil {
                self.forceUpdateStates()
            }
        }
    }

    private func forceUpdateStates() {
        self.homeService.status {states, error in
            if let _ = error {
                for callback in self.statesCallbacks {
                    callback([])
                }
                return
            }
            self.updateStates(states)
            for callback in self.statesCallbacks {
                callback(self._states)
            }
            self.statesCallbacks = []
        }
    }

    private func updateStates(newStates: [State]) {
        self._states = newStates

        self.updateWatchSession()
    }

    private func updateWatchSession() {
        let states = self._states.map { $0.jsonObject }
        let services = self._services.map { ["domain": $0.domain, "methods": $0.methods.map { method in method.jsonObject } ] }
        var message: [String: AnyObject] = ["states": states, "services": services]
        if let entityId = self.watchGlanceEntityId {
            message["watchGlanceEntity"] = entityId
        }
        if let entityId = self.watchComplicationEntityId {
            message["watchComplicationEntity"] = entityId
        }
        self.watchSession?.transferUserInfo(message)
    }

    private func login() {
        self.breakCache()
        self.sendWatchLoginCredentials()
    }

    private func sendWatchLoginCredentials() {
        guard self.loggedIn else { return }
        do {
            try self.watchSession?.updateApplicationContext(["backendURL": self._backendURL!.absoluteString, "backendPassword": self.backendPassword!])
        } catch let error as NSError {
            print("Error sending watch credentials: \(error)")
        }
    }

    private func breakCache() {
        self._services = []
        self._states = []

        self.forceUpdateStates()
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
            states = statesJson.reduce([State]()) {
                if let state = State(jsonObject: $1) {
                    return $0 + [state]
                }
                return $0
            }
        } else { states = [] }
        if let servicesJson = userInfo["services"] as? [[String: AnyObject]] {
            services = servicesJson.reduce([Service]()) {
                if let service = Service(jsonObject: $1) {
                    return $0 + [service]
                }
                return $0
            }
        } else { services = [] }
        if let glanceEntityId = userInfo["watchGlanceEntity"] as? String {
            self.homeRepository?.watchGlanceEntityId = glanceEntityId
        }
        if let complicationEntityId = userInfo["watchComplicationEntity"] as? String {
            self.homeRepository?.watchComplicationEntityId = complicationEntityId
        }
        self.didUpdateData?(states, services)
    }
}