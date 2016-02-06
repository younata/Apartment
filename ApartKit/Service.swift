import Foundation

public struct Service: Equatable {
    public let domain: String
    public let methods: [Method]

    public struct Method: Equatable, CustomStringConvertible {
        public let id: String
        public let descriptionString: String
        public let fields: [String: AnyObject]

        public var description: String {
            return "<Service.Method: id: \(self.id), description: '\(self.descriptionString)', fields: \(self.fields)>"
        }

        public var possibleValues: [String] {
            return Array(fields.keys)
        }

        init(id: String, description: String, fields: [String: AnyObject]) {
            self.id = id
            self.descriptionString = description
            self.fields = fields
        }
    }

    public init(domain: String, methods: [Method]) {
        self.domain = domain
        self.methods = methods
    }
}

extension Service: CustomStringConvertible {
    public var description: String {
        return "<Service: domain: \(self.domain), methods: \(self.methods)>"
    }
}

// MARK: - Serializable

extension Service {
    public var jsonObject: [String: AnyObject] {
        return [
            "domain": self.domain,
            "services": self.methods.map { $0.jsonObject }
        ]
    }

    public init?(jsonObject: [String: AnyObject]) {
        if let domain = jsonObject["domain"] as? String,
            let methodJson = jsonObject["services"] as? [String: AnyObject] {
                var methods = [Method]()
                for (key, value) in methodJson {
                    if let methodJson = value as? [String: AnyObject],
                        method = Method(id: key, jsonObject: methodJson) {
                            methods.append(method)
                    }
                }
                self.init(domain: domain, methods: methods)
        } else {
            return nil
        }
    }
}

extension Service.Method {
    public var jsonObject: [String: AnyObject] {
        return [self.id: ["description": self.description, "fields": self.fields]]
    }

    public init?(id: String, jsonObject: [String: AnyObject]) {
        if let description = jsonObject["description"] as? String,
            fields = jsonObject["fields"] as? [String: AnyObject] {
                self.init(id: id, description: description, fields: fields)
        } else {
            return nil
        }
    }
}

public func ==(a: Service, b: Service) -> Bool {
    return a.domain == b.domain && a.methods == b.methods
}

public func ==(a: Service.Method, b: Service.Method) -> Bool {
    return a.id == b.id
}