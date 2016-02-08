public struct Group: Equatable {
    public let groupEntity: State
    public let entities: [State]

    public init(groupEntity: State, entities: [State]) {
        self.groupEntity = groupEntity
        self.entities = entities
    }

    public init(data: (State, [State])) {
        self.init(groupEntity: data.0, entities: data.1)
    }
}

extension Group: CustomStringConvertible {
    public var description: String {
        let entitiesString = self.entities.reduce("") {
            return $0 + ",\n    \($1)"
        }
        return "<State: name: \(self.groupEntity.displayName), entities: [\(entitiesString)]>"
    }
}

extension Group: Serializable {
    public var jsonObject: [String: AnyObject] {
        return [
            "groupEntity": self.groupEntity.jsonObject,
            "entities": self.entities.map { $0.jsonObject },
        ]
    }

    public init?(jsonObject: [String : AnyObject]) {
        if let entityJson = jsonObject["groupEntity"] as? [String: AnyObject],
            groupEntity = State(jsonObject: entityJson),
            entitiesJson = jsonObject["entities"] as? [[String: AnyObject]] {
                let entities = entitiesJson.reduce([State]()) {
                    if let entity = State(jsonObject: $1) {
                        return $0 + [entity]
                    }
                    return $0
                }
                self.init(groupEntity: groupEntity, entities: entities)
        } else {
            return nil
        }
    }
}

public func ==(a: Group, b: Group) -> Bool {
    return a.groupEntity == b.groupEntity
}