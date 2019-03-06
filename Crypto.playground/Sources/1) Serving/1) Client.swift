import Foundation

/*
 This Client class represents a client that may want to execute a request on the server. It has a built in tatency that can be manipulated to allow for executions to fail if they are not performed in asequence that allows it, such as trying to transfer credit from one account to another if the from account does not exist or does not have sufficent credit.
 */

public protocol Client {
    var server: Server { get }
    var queue: DispatchQueue { get }
}

extension Client {
    public func fetch(url string: String,
                      method: String = "GET",
                      body: Any? = nil,
                      latency: UInt32 = 0,
                      resolve: Resolution? = nil) {
        guard let url = URL(string: string) else { return }
        queue.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(Int(latency))) {
            let request: URLRequest = {
                var request = URLRequest(url: url)
                request.httpMethod = method
                if let body = body,
                    let data = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted) {
                    request.httpBody = data
                }
                return request
            }()
            self.server.execute(request: request, resolve: resolve)
        }
    }
}
