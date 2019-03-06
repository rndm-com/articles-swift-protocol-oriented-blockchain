import Foundation

/*
 Our Block is the part of the chain that will validate against the parent objects, thereby ensuring that all links deriving from the genesis chain will be valid.
 */

public struct Block: Codable {
    
    // 1) When each block is created, we should assign a randomly generated UUID
    public let hash = UUID().uuidString
    
    // 2) The next three properties those we will initialise our block with
    public let payload: Payload // The data associated with this block
    public let transaction: String // A string defining the type of transaction
    public let previous: String? // The hash of the previous block in the chain or parent block
    public let index: Int // The index of the block in the chain
    
    // FIXME: Remove when not in source module
    public init(payload: Payload, transaction: String, previous: String?, index: Int){
        self.payload = payload
        self.transaction = transaction
        self.previous = previous
        self.index = index
    }
}
