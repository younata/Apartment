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

public func ==(a: Group, b: Group) -> Bool {
    return a.groupEntity == b.groupEntity
}