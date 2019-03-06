import Foundation

public extension Encodable {
    public var encoded: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    public var string: String {
        return String(describing: encoded?.toString())
    }
    
    public var json: Any? {
        guard let data = encoded else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
    }
}
