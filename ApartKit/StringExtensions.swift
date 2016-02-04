extension String {
    public var desnake: String {
        if self.isEmpty {
            return self
        }
        let unsnaked = self.stringByReplacingOccurrencesOfString("_", withString: " ")
        let first = unsnaked.startIndex
        let rest = first.successor()..<unsnaked.endIndex
        return unsnaked[first...first].uppercaseString + unsnaked[rest]
    }
}