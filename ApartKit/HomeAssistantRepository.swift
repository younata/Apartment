import Foundation
import WatchConnectivity

public protocol HomeRepositorySubscriber: NSObjectProtocol {
    func didUpdateStates(states: [State])
}

public class HomeAssistantRepository {
    private var _states = Array<State>()

    public let watchSession = WCSession.defaultSession()
    private let watchDelegate = WatchConnectivityDelegate()

    public let homeService: HomeAssistantService

    private let subscribers = NSHashTable.weakObjectsHashTable()

    public init(homeService: HomeAssistantService) {
        self.homeService = homeService
        self.watchDelegate.didUpdateStates = {
            self.updateStates($0)
        }
        self.watchSession.delegate = self.watchDelegate
    }

    public func addSubscriber(subscriber: HomeRepositorySubscriber) {
        self.subscribers.addObject(subscriber)
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

    public func states(forceUpdate: Bool, callback: ([State]) -> (Void)) {
        if !self._states.isEmpty && !forceUpdate {
            callback(self._states)
        }

        self.homeService.status {states, error in
            if let _ = error {
                callback([])
                return
            }
            self.updateStates(states)
            callback(self._states)
        }
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