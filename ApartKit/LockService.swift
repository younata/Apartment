import Foundation

public class LockService {
    public var backendURL: String
    public var authenticationToken: String
    let urlSession: NSURLSession

    public init(backendURL: String, urlSession: NSURLSession, authenticationToken: String) {
        self.backendURL = backendURL
        self.urlSession = urlSession
        self.authenticationToken = authenticationToken
    }
    
    public func allLocks(completionHandler: ([Lock]?, NSError?) -> (Void)) {
        self.getRequest(self.backendURL + "api/v1/locks") {result, error in
            if let _ = error {
                completionHandler(nil, error)
            } else if let res = result {
                let locks = res.reduce([Lock]()) {(locks, json) in
                    let lock = Lock(json: json)
                    return locks + [lock]
                }
                completionHandler(locks, nil)
            }
        }
    }
    
    public func lock(id: String, completionHandler: (Lock?, NSError?) -> (Void)) {
        self.getRequest(self.backendURL + "api/v1/locks/" + id) {result, error in
            if error != nil {
                completionHandler(nil, error)
            } else if let res = result?.first {
                let lock = Lock(json: res)
                completionHandler(lock, error)
            } else {
                let error = NSError(domain: "Apartment", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert \(result) to Lock object"])
                completionHandler(nil, error)
            }
        }
    }

    public func update_lock(lock: Lock, to_lock: Lock.LockStatus, completionHandler: (Lock?, NSError?) -> (Void)) {
        let shouldLock = to_lock == Lock.LockStatus.Unlocked ? "false" : "true"
        self.putRequest(self.backendURL + "api/v1/locks/" + lock.id + "?locked=\(shouldLock)") {result, error in
            if error != nil {
                completionHandler(nil, error)
            } else if let res = result {
                let lock = Lock(json: res)
                completionHandler(lock, error)
            } else {
                let error = NSError(domain: "Apartment", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert \(result) to Lock object"])
                completionHandler(nil, error)
            }
        }
    }

    // Mark: Private

    private func getRequest(url: String, callback: ([[String: AnyObject]]?, NSError?) -> (Void)) {
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        urlRequest.setValue("Token token=\(self.authenticationToken)", forHTTPHeaderField: "Authentication")
        self.urlSession.dataTaskWithRequest(urlRequest) {data, response, error in
            if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode < 300 {
                let statusCodeString = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode)
                let error = NSError(domain: "com.rachelbrindle.apartment.error.network", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: statusCodeString])
                callback(nil, error)
                return
            } else if let err = error {
                callback(nil, err)
                return
            } else if let data = data {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                    if let array = json as? [[String: AnyObject]] {
                        callback(array, nil)
                    } else if let object = json as? [String: AnyObject] {
                        callback([object], nil)
                    }
                    return
                } catch {}
            }
            callback(nil, NSError(domain: "com.rachelbrindle.apartment.error.generic", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown Error"]))
            }.resume()
    }

    private func putRequest(url: String, callback: ([String: AnyObject]?, NSError?) -> (Void)) {
        let urlRequest = NSMutableURLRequest(URL: NSURL(string: url)!)
        urlRequest.HTTPMethod = "PUT"
        urlRequest.setValue("Token token=\(self.authenticationToken)", forHTTPHeaderField: "Authentication")
        self.urlSession.dataTaskWithRequest(urlRequest) {data, response, error in
            if let httpResponse = response as? NSHTTPURLResponse where httpResponse.statusCode < 300 {
                let statusCodeString = NSHTTPURLResponse.localizedStringForStatusCode(httpResponse.statusCode)
                let error = NSError(domain: "com.rachelbrindle.apartment.error.network", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: statusCodeString])
                callback(nil, error)
                return
            } else if let err = error {
                callback(nil, err)
                return
            } else if let data = data {
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                    if let object = json as? [String: AnyObject] {
                        callback(object, nil)
                    }
                    return
                } catch {}
            }
            callback(nil, NSError(domain: "com.rachelbrindle.apartment.error.generic", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown Error"]))
            }.resume()
    }
}
