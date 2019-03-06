import Foundation

/*
 This error struct implements the Response protocol.
 */

public struct Error: Response {
    public let response: String = "ERROR"
    public let transaction: String
    public let reason: String
    
    // FIXME: Remove when not in source module
    public init(transaction: String, reason: String) {
        self.transaction = transaction
        self.reason = reason
    }
}
