import Foundation

public class LightsService {
    private let backendURL: String
    private let urlSession: NSURLSession
    private let authenticationToken: String
    public init(backendURL: String, urlSession: NSURLSession, authenticationToken: String) {
        self.backendURL = backendURL
        self.urlSession = urlSession
        self.authenticationToken = authenticationToken
    }

    public func allBulbs(completionHandler: ([Bulb]?, NSError?) -> (Void)) {
        self.getRequest(self.backendURL + "api/v1/bulbs") {result, error in
            if let _ = error {
                completionHandler(nil, error)
            } else if let res = result {
                let bulbs = res.reduce([Bulb]()) {(bulbs, json) in
                    if let bulb = Bulb(json: json) {
                        return bulbs + [bulb]
                    } else {
                        return bulbs
                    }
                }
                completionHandler(bulbs, nil)
            }
        }
    }

    public func bulb(id: Int, completionHandler: (Bulb?, NSError?) -> (Void)) {
        self.bulb("\(id)", completionHandler: completionHandler)
    }

    public func bulb(name: String, completionHandler: (Bulb?, NSError?) -> (Void)) {
        if let id = name.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet()) {
            self.getRequest(self.backendURL + "api/v1/bulb/" + id) {result, error in
                if error != nil {
                    completionHandler(nil, error)
                } else if let res = result?.first,
                          let bulb = Bulb(json: res) {
                    completionHandler(bulb, error)
                } else {
                    let error = NSError(domain: "Apartment", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert \(result) to Bulb object"])
                    completionHandler(nil, error)
                }
            }
        }
    }

    public func update(bulb: Bulb, attributes: [String: AnyObject], completionHandler: (Bulb?, NSError?) -> (Void)) {
        let id = bulb.id

        func generateQuery(parameters: [String: AnyObject]) -> String {
            var components: [(String, String)] = []
            for key in Array(parameters.keys).sort(<) {
                let value : AnyObject = parameters[key]!
                components += [key: "\(value.description)"]
            }

            return "&".join(components.map{"\($0)=\($1)"} as [String])
        }

        let query = "?" + generateQuery(attributes)

        self.putRequest(self.backendURL + "api/v1/bulb/\(id)" + query) {result, error in
            if error != nil {
                completionHandler(nil, error)
            } else if let res = result, let bulb = Bulb(json: res) {
                completionHandler(bulb, error)
            } else {
                let error = NSError(domain: "Apartment", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unable to convert \(result) to Bulb object"])
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
        }?.resume()
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
        }?.resume()
    }
}