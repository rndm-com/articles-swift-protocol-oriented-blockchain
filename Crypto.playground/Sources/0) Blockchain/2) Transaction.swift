import Foundation

/*
 In order to define our transactions we will use an enumeration. In this specific case, we will use enums with associated values.
 */

public enum Transaction {
    case creation(account: String, value: Int)
    case exchange(from: String, to: String, value: Int)
    case value(of: String)
}

extension Transaction {
    public static let creationDescription = "creation"
    public static let additionDescription = "addition"
    public static let subtractionDescription = "subtraction"
    public static let exchangeDescription = "exchange"
    public static let valueDescription = "value"
    
    public static func isValueTransaction(input: String) -> Bool {
        return [valueDescription, creationDescription].contains(input)
    }
}

extension Transaction: CustomStringConvertible {
    public var description: String {
        switch self {
        case .creation: return Transaction.creationDescription
        case .exchange: return Transaction.exchangeDescription
        case .value: return Transaction.valueDescription
        }
    }
}
