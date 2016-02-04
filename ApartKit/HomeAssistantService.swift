import Foundation

class HomeAssistantService {
    var baseURL: NSURL!
    var apiKey: String?
    let urlSession: NSURLSession
    let mainQueue: NSOperationQueue
    let dateFormatter = NSDateFormatter()

    init(urlSession: NSURLSession, mainQueue: NSOperationQueue) {
        self.urlSession = urlSession
        self.mainQueue = mainQueue

        self.dateFormatter.dateFormat = "HH:mm:ss dd-MM-yyyy"
    }

    func apiAvailable(callback: Bool -> Void) {
        let url = self.baseURL
        let request = NSMutableURLRequest(URL: url)
        request.addValue(self.apiKey ?? "", forHTTPHeaderField: "x-ha-access")
        self.urlSession.dataTaskWithRequest(request) {data, response, error in
            if let _ = error {
                self.mainQueue.addOperationWithBlock {
                    callback(false)
                }
            } else if let data = data, objects = try? NSJSONSerialization.JSONObjectWithData(data, options: []), dictionary = objects as? [String: AnyObject] where dictionary["message"] as? String == "API running." {
                self.mainQueue.addOperationWithBlock {
                    callback(true)
                }
            } else  {
                self.mainQueue.addOperationWithBlock {
                    callback(false)
                }
            }
        }.resume()
    }

    // MARK: Events

    func events(callback: ([Event], NSError?) -> (Void)) {
        let url = self.baseURL.URLByAppendingPathComponent("events")
        let request = NSMutableURLRequest(URL: url)
        request.addValue(self.apiKey ?? "", forHTTPHeaderField: "x-ha-access")
        self.urlSession.dataTaskWithRequest(request) {data, response, error in
            if let _ = error {
                self.mainQueue.addOperationWithBlock {
                    callback([], error)
                }
            } else if let data = data, objects = try? NSJSONSerialization.JSONObjectWithData(data, options: []), dictionaries = objects as? [[String: AnyObject]] {
                var ret = Array<Event>()
                for dictionary in dictionaries {
                    if let name = dictionary["event"] as? String,
                        listeners = dictionary["listener_count"] as? Int {
                            ret.append(Event(name: name, listenerCount: listeners))
                    }
                }
                self.mainQueue.addOperationWithBlock {
                    callback(ret, nil)
                }
            } else  {
                let error = NSError(domain: "", code: 0, userInfo: nil)
                self.mainQueue.addOperationWithBlock {
                    callback([], error)
                }
            }
        }.resume()
    }

    func fireEvent(event: String, data: [String: AnyObject]?, callback: (String?, NSError?) -> (Void)) {
        let url = self.baseURL.URLByAppendingPathComponent("events", isDirectory: true).URLByAppendingPathComponent(event)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        if let data = data {
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(data, options: [])
        }
        request.addValue(self.apiKey ?? "", forHTTPHeaderField: "x-ha-access")
        self.urlSession.dataTaskWithRequest(request) {data, response, error in
            if let _ = error {
                self.mainQueue.addOperationWithBlock {
                    callback(nil, error)
                }
            } else if let data = data,
                object = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                dictionary = object as? [String: AnyObject],
                message = dictionary["message"] as? String {
                    self.mainQueue.addOperationWithBlock {
                        callback(message, nil)
                    }
            } else  {
                let error = NSError(domain: "", code: 0, userInfo: nil)
                self.mainQueue.addOperationWithBlock {
                    callback(nil, error)
                }
            }
        }.resume()
    }

    // MARK: Services

    func services(callback: ([Service], NSError?) -> (Void)) {
        let url = self.baseURL.URLByAppendingPathComponent("services")
        let request = NSMutableURLRequest(URL: url)
        request.addValue(self.apiKey ?? "", forHTTPHeaderField: "x-ha-access")
        self.urlSession.dataTaskWithRequest(request) {data, response, error in
            if let _ = error {
                self.mainQueue.addOperationWithBlock {
                    callback([], error)
                }
            } else if let data = data,
                object = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                dictionaries = object as? [[String: AnyObject]] {
                    var ret = Array<Service>()
                    for dictionary in dictionaries {
                        if let name = dictionary["domain"] as? String,
                            services = dictionary["services"] as? [String: AnyObject] {
                                ret.append(Service(domain: name, services: Array(services.keys)))
                        }
                    }
                    self.mainQueue.addOperationWithBlock {
                        callback(ret, nil)
                    }
            } else {
                let error = NSError(domain: "", code: 0, userInfo: nil)
                self.mainQueue.addOperationWithBlock {
                    callback([], error)
                }
            }
        }.resume()
    }

    func callService(service: String, method: String, data: [String: AnyObject]?, callback: ([State], NSError?) -> (Void)) {
        let url = self.baseURL.URLByAppendingPathComponent("services", isDirectory: true).URLByAppendingPathComponent("\(service)/\(method)")
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        if let data = data {
            request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(data, options: [])
        }
        request.addValue(self.apiKey ?? "", forHTTPHeaderField: "x-ha-access")
        self.urlSession.dataTaskWithRequest(request) {data, response, error in
            if let _ = error {
                self.mainQueue.addOperationWithBlock {
                    callback([], error)
                }
            } else if let data = data,
                object = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
                dictionaries = object as? [[String: AnyObject]] {
                    var ret = Array<State>()
                    for dictionary in dictionaries {
                        if let state = self.parseState(dictionary) {
                            ret.append(state)
                        }
                    }
                    self.mainQueue.addOperationWithBlock {
                        callback(ret, nil)
                    }
            } else  {
                let error = NSError(domain: "", code: 0, userInfo: nil)
                self.mainQueue.addOperationWithBlock {
                    callback([], error)
                }
            }
        }.resume()
    }

    // MARK: States

    func status(callback: ([State], NSError?) -> (Void)) {
        let url = self.baseURL.URLByAppendingPathComponent("states")
        let request = NSMutableURLRequest(URL: url)
        request.addValue(self.apiKey ?? "", forHTTPHeaderField: "x-ha-access")
        self.urlSession.dataTaskWithRequest(request) {data, response, error in
            if let _ = error {
                self.mainQueue.addOperationWithBlock {
                    callback([], error)
                }
            } else if let data = data, objects = try? NSJSONSerialization.JSONObjectWithData(data, options: []), dictionaries = objects as? [[String: AnyObject]] {
                var ret = Array<State>()
                for dictionary in dictionaries {
                    if let state = self.parseState(dictionary) {
                        ret.append(state)
                    }
                }
                self.mainQueue.addOperationWithBlock {
                    callback(ret, nil)
                }
            } else  {
                let error = NSError(domain: "", code: 0, userInfo: nil)
                self.mainQueue.addOperationWithBlock {
                    callback([], error)
                }
            }
        }.resume()
    }

    func status(entityId: String, callback: (State?, NSError?) -> (Void)) {
        let url = self.baseURL.URLByAppendingPathComponent("states", isDirectory: true).URLByAppendingPathComponent(entityId)
        let request = NSMutableURLRequest(URL: url)
        request.addValue(self.apiKey ?? "", forHTTPHeaderField: "x-ha-access")
        self.urlSession.dataTaskWithRequest(request) {data, response, error in
            self.parseStatusUpdate(data, response: response, error: error, callback: callback)
        }.resume()
    }

    func update(entityId: String, newStatus: String, callback: (State?, NSError?) -> (Void)) {
        let url = self.baseURL.URLByAppendingPathComponent("states", isDirectory: true).URLByAppendingPathComponent(entityId)
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.HTTPBody = try? NSJSONSerialization.dataWithJSONObject(["state": newStatus], options: [])
        request.addValue(self.apiKey ?? "", forHTTPHeaderField: "x-ha-access")
        self.urlSession.dataTaskWithRequest(request) {data, response, error in
            self.parseStatusUpdate(data, response: response, error: error, callback: callback)
        }.resume()
    }

    // MARK: Private

    private func parseState(dictionary: [String: AnyObject]) -> State? {
        if let attributes = dictionary["attributes"] as? [String: AnyObject],
            entityId = dictionary["entity_id"] as? String,
            lastChangedStr = dictionary["last_changed"] as? String,
            lastChanged = self.dateFormatter.dateFromString(lastChangedStr),
            lastUpdatedStr = dictionary["last_updated"] as? String,
            lastUpdated = self.dateFormatter.dateFromString(lastUpdatedStr),
            state = dictionary["state"] as? String {
                return State(attributes: attributes, entityId: entityId, lastChanged: lastChanged, lastUpdated: lastUpdated, state: state)
        }
        return nil
    }

    private func parseStatusUpdate(data: NSData?, response: NSURLResponse?, error: NSError?, callback: (State?, NSError?) -> (Void)) {
        if let _ = error {
            self.mainQueue.addOperationWithBlock {
                callback(nil, error)
            }
        } else if let data = data,
            object = try? NSJSONSerialization.JSONObjectWithData(data, options: []),
            dictionary = object as? [String: AnyObject],
            state = self.parseState(dictionary) {
                self.mainQueue.addOperationWithBlock {
                    callback(state, nil)
                }
        } else  {
            let error = NSError(domain: "", code: 0, userInfo: nil)
            self.mainQueue.addOperationWithBlock {
                callback(nil, error)
            }
        }
    }
}
