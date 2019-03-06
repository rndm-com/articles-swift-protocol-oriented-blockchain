import Foundation

/*
 This Server class mocks out a block chain server. It allows for an execution method with a URLRequest to be processed and a resolution that is passed back to the respective entity.
 */
public class Server {
    
    private typealias Elements = (components: URLComponents, method: Method, path: Path, current: Int, request: URLRequest)
    
    private var chain = Chain()
    private var index = 0
    
    // FIXME: Remove when not in source module
    public init() {}
    
    private func guarding(request: URLRequest, current: Int, resolve: Resolution?) -> Elements? {
        guard let url = request.url else {
            resolve?(Error(transaction: "undefined", reason: "Failed to parse valid URL"), current)
            return nil
        }
        
        guard let components = URLComponents(string: url.absoluteString) else {
            resolve?(Error(transaction: "undefined", reason: "Failed to parse valid URL components"), current)
            return nil
        }
        
        guard let method = Method(rawValue: request.httpMethod ?? Method.get.rawValue) else {
            resolve?(Error(transaction: "undefined", reason: "Unsupported method"), current)
            return nil
        }
        
        guard let path = Path(rawValue: components.path) else {
            resolve?(Error(transaction: "undefined", reason: "Unsupported url Path"), current)
            return nil
        }
        
        return (components: components, method: method, path: path, current: current, request: request)
    }
    
    private func get(elements: Elements, resolve: Resolution?) {
        switch elements.path {
        case .value:
            guard let account = elements.components.queryItems?.last(where: { $0.name == "account" })?.value else {
                resolve?(Error(transaction: elements.path.description, reason: "No account supplied"), elements.current)
                return
            }
            guard let found = chain.find(account: account) else {
                resolve?(Error(transaction: elements.path.description, reason: "Invalid account: \(account)"), elements.current)
                return
            }
            resolve?(Chain(chain: [found]), elements.current)
            return
        case .chain:
            resolve?(chain, elements.current)
            return
        default:
            resolve?(Error(transaction: elements.path.description, reason: "Invalid method '\(elements.method.rawValue)' for transaction \(elements.path.description)"), elements.current)
            return
        }
    }
    
    private func post(elements: Elements, resolve: Resolution?) {
        guard let body = elements.request.httpBody else {
            resolve?(Error(transaction: elements.path.description, reason: "No body supplied"), elements.current)
            return
        }
        switch elements.path {
        case .creation:
            guard let instance = try? JSONDecoder().decode(Creation.self, from: body) else {
                resolve?(Error(transaction: elements.path.description, reason: "Invalid method body for transaction \(elements.path.description)"), elements.current)
                return
            }
            let response = self.chain.transact(transaction: .creation(account: instance.account, value: instance.value ?? 0))
            self.chain = (response as? Chain) ?? self.chain
            resolve?(response, elements.current)
            return
        case .exchange:
            guard let instance = try? JSONDecoder().decode(Exchange.self, from: body) else {
                resolve?(Error(transaction: elements.path.description, reason: "Invalid method body for transaction \(elements.path.description)"), elements.current)
                return
            }
            let response = self.chain.transact(transaction: .exchange(from: instance.from, to: instance.to, value: instance.value))
            self.chain = (response as? Chain) ?? self.chain
            resolve?(response, elements.current)
            return
        default:
            resolve?(Error(transaction: elements.path.description, reason: "Invalid method '\(elements.method.rawValue)' for transaction \(elements.path.description)"), elements.current)
            return
        }
    }
    
    public func execute(request: URLRequest, resolve: Resolution? = nil) {
        let current = self.index
        self.index += 1
        guard let elements = guarding(request: request, current: current, resolve: resolve) else { return }
        switch elements.method {
        case .get: get(elements: elements, resolve: resolve)
        case .post: post(elements: elements, resolve: resolve)
        }
    }
}

extension Server {
    private enum Method: String {
        case get = "GET"
        case post = "POST"
    }
    
    private enum Path: String {
        case value = "/value"
        case chain = "/chain"
        case creation = "/creation"
        case exchange = "/exchange"
        
        var description: String {
            return String(rawValue.dropFirst())
        }
    }
}

extension Server {
    private struct Creation: Codable {
        let account: String
        let value: Int?
    }
    
    private struct Exchange: Codable {
        let to: String
        let from: String
        let value: Int
    }
}
