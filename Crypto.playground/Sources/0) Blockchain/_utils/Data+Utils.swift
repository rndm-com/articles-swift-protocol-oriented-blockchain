import Foundation

public extension Data {
    public func toString(encoding: String.Encoding = .utf8) -> String {
        return String(data: self, encoding: encoding) ?? ""
    }
}
