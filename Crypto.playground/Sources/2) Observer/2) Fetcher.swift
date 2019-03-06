import Foundation

public struct Fetcher: Observable {
    public static var observers: [String: [String: Observer]] = [:]
    public let identifier = UUID().string
    
    let client: Client
}

extension Fetcher {
    public static func fetch(fetches: [Fetch]? = nil, initial: Int = 10_000_000, maximum: Int = 1_000, count: Int = 1_000, observer: Observable, client: Client) {
        
        let resolution: Resolution = {
            let _ = $1
            observer.notify(withData: $0)
        }
        
        (fetches ?? generated(count: count)).forEach {
            client.fetch(url: $0.url, method: $0.method, body: $0.body, latency: $0.latency, resolve: resolution)
        }
    }
    
    func fetch(fetches: [Fetch]? = nil, initial: Int = 10_000_000, maximum: Int = 1_000, count: Int = 1000) {
        Fetcher.fetch(fetches: fetches, initial: initial, maximum: maximum, count: count, observer: self, client: client)
    }
}

extension Fetcher {
    private enum Accounts {
        case base
        case existing
        case new
        
        static var accounts: [String] = []
    }
    
    private static func getFrom() -> Accounts {
        let random = arc4random() % 100
        switch random {
        case 0...50: return .base
        default: return .existing
        }
    }
    
    private static func getTo() -> Accounts {
        let random = arc4random() % 100
        switch random {
        case 0...50: return .new
        case 51...80: return .existing
        default: return .base
        }
    }
    
    private static func getAccount(input: Accounts) -> String {
        switch input {
        case .new:
            let output = UUID().uuidString
            Accounts.accounts.append(output)
            return output
        case .base: return Accounts.accounts.first ?? getAccount(input: .new)
        case .existing: return Accounts.accounts.dropFirst().shuffled()[0]
        }
    }
}

extension Fetcher {
    public typealias Fetch = (url: String, method: String, body: Any?, latency: UInt32)
    
    public static func generated(initial: Int = 10_000_000, maximum: Int = 1_000, count: Int = 1_000) -> [Fetch] {
        let fetches: [Fetch] =  (0...count).map {
            let latency: UInt32 = UInt32($0)
            switch $0 {
            case 0:
                return (url: "http://test.com/creation", method: "POST", body: ["account": getAccount(input: .base), "value": initial], latency: latency)
            case 1:
                return (url: "http://test.com/exchange", method: "POST", body: ["from": getAccount(input: .base), "to": getAccount(input: .new), "value": arc4random() % UInt32(maximum) + 1], latency: latency)
            default:
                return (url: "http://test.com/exchange", method: "POST", body: ["from": getAccount(input: getFrom()), "to": getAccount(input: getTo()), "value": arc4random() % UInt32(maximum) + 1], latency: latency)
            }
        }
        return fetches
    }
}
