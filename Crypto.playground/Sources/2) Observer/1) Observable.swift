import Foundation

public protocol Observable {
    static var observers: [String: [String: Observer]] { get set }
    var identifier: String { get }
}

extension Observable {
    public var observers: [String: Observer]? {
        if let owned = Self.observers[identifier] {
            return owned
        }
        Self.observers.updateValue([:], forKey: identifier)
        return Self.observers[identifier]
    }
    
    public func register(observer: Observer, forKey key: String) {
        if var current = observers {
            current.updateValue(observer, forKey: key)
            Self.observers.updateValue(current, forKey: identifier)
        } else {
            Self.observers.updateValue([key: observer], forKey: identifier)
        }
    }
    public func deregister(withKey key: String) {
        if var current = observers {
            current.removeValue(forKey: key)
            Self.observers.updateValue(current, forKey: identifier)
        }
    }
    
    public func notify(withData data: Any?) {
        observers?.values.forEach { $0.didUpdate(withData: data) }
    }
}
