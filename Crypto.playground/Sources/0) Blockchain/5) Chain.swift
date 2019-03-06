import Foundation

/*
    Now on to the meat of our concept. Here we have another struct called Chain. By its very nature a Struct is immutable, and so when we create a chain we will have to take the previous chain, add another transaction and return a new version of that chain.
 */

public struct Chain {
    public let response: String = "SUCCESS"
    fileprivate let chain: [Block]
    public init(chain: [Block] = []) {
        self.chain = chain
    }
}

extension Chain {
    // We can also traverse the chain from start to end verifying that the child parent relationship is intact.
    public var isValid: Bool {
        return chain.reduce(true) {
            $0 && ($1.index + 1 == chain.count || chain[$1.index + 1].previous == $1.hash)
        }
    }
    
    // This method will help us in validating the current amount in each account
    public var accounts: [String: Int] {
        return chain.reduce([String: Int](), {
            var output = $0
            if ([Transaction.valueDescription, Transaction.creationDescription].contains($1.transaction)) {
                output[$1.payload.account] = $1.payload.value
            }
            return output
        })
    }
}

extension Chain {
    
    // This method will help find the last instance of when a block was either created or had its value updated.
    public func find(account: String) -> Block? {
        for i in stride(from: chain.count - 1, through: 0, by: -1) {
            let block = chain[i]
            if block.payload.account == account && [Transaction.valueDescription, Transaction.creationDescription].contains(block.transaction)  {
                return block
            }
        }
        return nil
    }
}

extension Chain: CustomStringConvertible {
    public var description: String {
        return string
    }
}

// This extension provides the real functionality behind our chain process
extension Chain: Response {
    
    /*
        The create method is used for two reasons:
        1) We want to create a genesis account
        2) We want to create a new account on the chain
     */
    
    public func create(payload: Payload, transaction: String) -> Response {
        guard isValid else { return Error(transaction: transaction.description, reason: "status - INVALID") }
        var chain = self.chain
        chain.append(Block(payload: payload, transaction: transaction, previous: chain.last?.hash, index: chain.count))
        return Chain(chain: chain)
    }
    
    // The transact method helps us build the transaction on the chain:
    public func transact(transaction: Transaction) -> Response {
        /*
            We only care about two types of transaction at this level: creation and exchange
         - Creation: as above a genesis, which allows an an inital input of a initial value, or a new account which will generate an account under the id given with a zero value
         - Exchange: a suite of transactions that shows an addition, subtraction and two value transactions giving the final value for each of both of the accounts
        */
        switch transaction {
        case .creation(account: let account, value: let value):
            if let _ = find(account: account) {
                return Error(transaction: transaction.description, reason: "account '\(account)' already exists")
            }
            return create(payload: Payload(value: chain.count > 0 ? 0 : value, account: account), transaction: Transaction.creationDescription)
        case .exchange(from: let from, to: let to, value: let value):
            if (value <= 0) { return Error(transaction: transaction.description, reason: "value must be greater than 0") }
            if (to == from) { return Error(transaction: transaction.description, reason: "account identifiers must not be the same") }
            guard let fromAccount = find(account: from) else { return Error(transaction: transaction.description, reason: "the from account '\(from)' does not exist") }
            if (fromAccount.payload.value < value) { return Error(transaction: transaction.description, reason: "the from account does not contain enough credits") }
            let toAccount = find(account: to)
            return (toAccount != nil ? self : transact(transaction: Transaction.creation(account: to, value: 0)))
                .create(payload: Payload(value: -value, account: from), transaction: Transaction.subtractionDescription)
                .create(payload: Payload(value: value, account: to), transaction: Transaction.additionDescription)
                .create(payload: Payload(value: (toAccount?.payload.value ?? 0) + value, account: to), transaction: Transaction.valueDescription)
                .create(payload: Payload(value: fromAccount.payload.value - value, account: from), transaction: Transaction.valueDescription)
        default: return self
        }
    }
}

// With this method we are able to ensure that a Chain is equal to another Chain
public func == (lhs: Chain, rhs: Chain) -> Bool {
    return lhs.chain.count == rhs.chain.count
        && lhs.chain.reduce(true, {
            return $0
                && rhs.chain[$1.index].hash == $1.hash
                && rhs.chain[$1.index].payload == $1.payload
        })
}
