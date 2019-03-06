import Foundation

/*
 This protocol will help us in buidlding out a response interface for our block chain. Currently, we will have two types:
 - Success: This will result in a transaction or series of transactions on our blockchain
 - Error: This will not result in a transaction
 */

public protocol Response: Codable, CustomStringConvertible {
    var response: String { get }
    func transact(transaction: Transaction) -> Response
    func create(payload: Payload, transaction: String) -> Response
}

// This extension will make the create and transact methods optional
extension Response {
    public func create(payload: Payload, transaction: String) -> Response {
        return self
    }
    public func transact(transaction: Transaction) -> Response {
        return self
    }
}

// This extension allows us to conform to the CustomStringConvertible protocol
extension Response {
    public var description: String {
        return string
    }
}
