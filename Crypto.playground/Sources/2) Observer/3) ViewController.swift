import UIKit

public class ViewController: UITableViewController {
    
    private enum ViewStyle {
        case accounts
        case chain
    }
    
    public let queue = DispatchQueue(label: "background_queue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
    public let server = Server()
    
    private var chain: [Block] = []
    private var accounts: [Payload] = []
    
    private var viewStyle: ViewStyle = .accounts
    
    public init () {
        super.init(style: .grouped)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(style: .grouped)
        initialize()
    }
    
    func initialize() {
        tableView.register(UITableViewCell.classForKeyedArchiver(), forCellReuseIdentifier: "CELL")
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetcher.fetch()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : viewStyle == .accounts ? accounts.count : chain.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELL") ?? UITableViewCell()
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Switch view"
        default:
            switch viewStyle {
            case .accounts:
                let payload = accounts[indexPath.row]
                cell.textLabel?.text = "\(payload.account): \(payload.value)"
                
            case .chain:
                let block = chain[indexPath.row]
                cell.textLabel?.text = "\(block.transaction) - \(block.payload.account): \(block.payload.value)"
            }
        }
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.section == 0 && indexPath.row == 0) {
            switch (viewStyle) {
            case .chain: viewStyle = .accounts
            case .accounts: viewStyle = .chain
            }
            tableView.reloadData()
        }
    }
}

extension ViewController: Observer {
    public func didUpdate(withData data: Any?) {
        queue.async {
            if
                let response = data as? Response,
                let json = response.json as? [String: Any],
                let value = json["response"] as? String,
                value == "SUCCESS",
                let responseChain = json["chain"] as? [[String: Any]]
            {
                let chain: [Block] = responseChain.compactMap {
                    guard let data = try? JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted) else { return nil }
                    return try? JSONDecoder().decode(Block.self, from: data)
                }
                let reduced = (chain.reduce([String: Payload](), {
                    var res = $0
                    if (Transaction.isValueTransaction(input: $1.transaction)) {
                        res[$1.payload.account] = $1.payload
                    }
                    return res
                }))
                
                DispatchQueue.main.async {
                    self.chain = chain
                    self.accounts = reduced.values.sorted { $0.value > $1.value }
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension ViewController: Client {
    var fetcher: Fetcher {
        return {
            $0.register(observer: self, forKey: "key")
            return $0
        }(Fetcher(client: self))
    }
}
