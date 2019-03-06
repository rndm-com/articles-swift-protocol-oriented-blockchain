import Foundation

public protocol Observer {
    func didUpdate(withData data: Any?)
}

extension Observer {
    public func didUpdate(withData data: Any?) {}
}
