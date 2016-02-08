public protocol Serializable {
    var jsonObject: [String: AnyObject] { get }

    init?(jsonObject: [String: AnyObject])
}