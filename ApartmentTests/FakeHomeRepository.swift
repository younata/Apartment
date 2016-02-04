import ApartKit

class FakeHomeRepository: HomeRepository {
    var backendURL: NSURL!
    var backendPassword: String!

    init() {}

    var apiAvailableCallback: (Bool -> Void)?
    func apiAvailable(callback: Bool -> Void) {
        apiAvailableCallback = callback
    }

    var subscribers = [HomeRepositorySubscriber]()
    func addSubscriber(subscriber: HomeRepositorySubscriber) {
        subscribers.append(subscriber)
    }

    var statesCallback: ([State] -> Void)?
    func states(callback: [State] -> Void) {
        statesCallback = callback
    }

    var servicesCallback: ([Service] -> Void)?
    func services(callback: [Service] -> Void) {
        servicesCallback = callback
    }

    var updateServiceService: Service? = nil
    var updateServiceMethod: String? = nil
    var updateServiceEntity: State? = nil
    var updateServiceCallback: (([State], NSError?) -> Void)?
    func updateService(service: Service, method: String, onEntity: State, callback: ([State], NSError?) -> Void) {
        updateServiceService = service
        updateServiceMethod = method
        updateServiceEntity = onEntity
        updateServiceCallback = callback
    }
}