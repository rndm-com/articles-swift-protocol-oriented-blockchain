import Foundation

/*
 Our payload is the data we want to associate with any given block.
 
 In this instance we are thingking about only creating a chain that allows for transaction from one account to another. Therefore, the entire payload can comprise of two sliple properties:
 
 - account: a string value identifying the account
 - value: an integer value for the amount we are working with
 */

public struct Payload {
    public let value: Int
    public let account: String
    
    // FIXME: Remove when not in source module
    public init(value: Int, account: String) {
        self.value = value
        self.account = account
    }
}

extension Payload: Codable {}

extension Payload: CustomStringConvertible {
    public var description: String {
        return string
    }
}

extension Payload: Equatable {}

// With this method we are able to ensure that a Payload is equal to another Payload
public func == (lhs: Payload, rhs: Payload) -> Bool {
    return lhs.description == rhs.description
}
