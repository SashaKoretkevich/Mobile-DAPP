import Web3
import UIKit
import Web3PromiseKit
import Web3ContractABI
import BigInt

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    var devices: [Devices] = getAllDevices()
    private var refresh = UIRefreshControl()
    
    static let power   = pow(10.0, 18.0)
    static let jsonString = """
    Here you paste your ABI of the smart contract in the format of JSON string
    """.data(using: .utf8)!

    
    static let web3 = Web3(rpcURL: "Here you should paste the RPC link that will help to connect to the blockchain network")
    static let contractAddress = try! EthereumAddress(hex: "Here you should paste address of the smart contract", eip55: true)
    static let walletAddress = try! EthereumAddress(hex: "Here you should paste wallet address of the manager", eip55: true)
    static let privateKey = try! EthereumPrivateKey(hexPrivateKey: "Here you should paste private key of the manager wallet")
    static let tag = EthereumQuantityTag(tagType: .latest)
    var tableViewDevices = UITableView()
    
    static func contract() -> DynamicContract {
        let contract = try! web3.eth.Contract(json: jsonString, abiKey: nil, address: contractAddress)
        return contract
    }

    static func callFun(input: String, contract: DynamicContract) -> ((ABIEncodable...) -> SolidityInvocation)?{
         let result: ((ABIEncodable...) -> SolidityInvocation)? = contract[input]
         return result
     }

    static func getAllDevices() -> [Devices]{
        var devices: [Devices] = []
        let contract = HomeViewController.contract()
        let call = try! callFun(input: "getAllDevices", contract: contract)!().call().wait()
        let array: [[String: Any]] = call[""]! as! [[String : Any]]
        for arr in array{
            devices.append(Devices(type: arr["deviceType"] as! String, balance: arr["deviceBalance"] as! BigUInt, certified: arr["isCertified"] as! Bool, address: arr["deviceAddress"]! as! EthereumAddress))
        }
        return devices
    }
    
}
extension HomeViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All devices"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(add))
        navigationItem.rightBarButtonItem?.tintColor = .systemGreen

        configureTableViewUsers()
        refresh.addTarget(self, action: #selector(ref), for: UIControl.Event.valueChanged)
        tableViewDevices.addSubview(refresh)
    }
    
    @objc func ref(send: UIRefreshControl){
        DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
            self.tableViewDevices.reloadData()
            self.refresh.endRefreshing()
        }
    }
    
    @objc func copyAddress(_ sender: UIButton!){
        if let indexPath = tableViewDevices.indexPathForRow(at: sender.convert(sender.bounds.origin, to: tableViewDevices)){
            let rowIndex =  indexPath.row
            UIPasteboard.general.string = try! String((devices[rowIndex].address).hex(eip55: true))
        }
        
        UIView.animate(withDuration: 0.3, animations: {
                sender.setImage(UIImage(systemName: "checkmark"), for: .normal)
            sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
            }) { (_) in
                UIView.animate(withDuration: 0.5, animations: {
                    sender.transform = .identity
                }) { (_) in
                    UIView.animate(withDuration: 0.3, animations: {
                        sender.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
                    })
                }
            }
    }
    
    func configureTableViewUsers(){
        view.addSubview(tableViewDevices)
        tableViewDevices.frame = view.bounds
        tableViewDevices.dataSource = self
        tableViewDevices.delegate = self
        
        tableViewDevices.register(Cell.self, forCellReuseIdentifier: "cell")
        tableViewDevices.rowHeight  = 130
    }
    
    static func certify(_ deviceAddress: EthereumAddress, _ deviceCert: Bool){
        let address = deviceAddress
        let cer = deviceCert
        let contract = HomeViewController.contract()
        let nonce = try! HomeViewController.web3.eth.getTransactionCount(address: HomeViewController.walletAddress, block: HomeViewController.tag).wait()
        var call: any SolidityInvocation
        if cer == false{
            call = HomeViewController.callFun(input: "deviceCertification", contract: contract)!(address)
        }
        else{
            call = HomeViewController.callFun(input: "deviceUncertify", contract: contract)!(address)
        }
        let gasPrice = try! HomeViewController.web3.eth.gasPrice().wait()
        guard let transaction = call.createTransaction(nonce: nonce, gasPrice: gasPrice, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 500000, gasLimit: 500000, from: HomeViewController.walletAddress, value: 0, accessList: [:], transactionType: .eip1559)
        else {
            return
        }
        let signedTx = try! transaction.sign(with: HomeViewController.privateKey, chainId: 11155111).guarantee.wait()
        firstly {
            HomeViewController.web3.eth.sendRawTransaction(transaction: signedTx)
        }.done {
            recipt in HomeViewController.web3.eth.getTransactionByHash(blockHash: recipt){
                txRecipt in print(txRecipt)
            }
        }.catch { error in
            print(error)}
    }

    
    @objc func cer(_ sender: UIButton!){
        if let indexPath = tableViewDevices.indexPathForRow(at: sender.convert(sender.bounds.origin, to: tableViewDevices)){
            HomeViewController.certify(devices[indexPath.row].address, devices[indexPath.row].certified)
        }
    }
    
    @objc func add(_ sender: specialButtons!) {
        
        let navi = UINavigationController(rootViewController: addViewController())
        if let sheetNew = navi.sheetPresentationController{
            sheetNew.detents = [.custom { _ in return 350}]
        }
        navigationController?.present(navi, animated: true)
    }
    
    static func getBalance(address: EthereumAddress) -> BigUInt{
        let address = address
        let balance = try! HomeViewController.web3.eth.getBalance(address: address, block: HomeViewController.tag).wait()
        return balance.quantity
        }
    
    static func devBalanceRound(balance: Double) -> String
    {
        let balance = round(((balance / HomeViewController.power) * 10000)) / 10000
        var text: String = ""
        if balance == 0.0{
            text = "0"
        }
        else{
            text = String(balance)
        }
        return text
    }
}
extension HomeViewController{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        devices = HomeViewController.getAllDevices()
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! Cell
            let device = devices[indexPath.row]
            cell.type.text = device.type
            cell.addressHex.text = try! String(device.address.hex(eip55: true))
            cell.balance.text = HomeViewController.devBalanceRound(balance: Double(device.balance))
            if device.certified == false{
                cell.auth.text = "uncertified"
                cell.auth.backgroundColor = .systemPink
            }
            else{
                cell.auth.text = "certified"
                cell.auth.backgroundColor = .systemGreen
            }
            cell.copy.addTarget(self, action: #selector(copyAddress), for: .touchUpInside)
            return cell
        }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(AdcellViewController(indexCell: indexPath.row), animated: true)
    }
    
}

struct Devices {
    var type: String
    var balance: BigUInt
    var certified: Bool
    var address: EthereumAddress
}

class Cell: UITableViewCell{
    let type        = UILabel()
    let balance     = UILabel()
    let bal         = UILabel()
    let addressHex  = UILabel()
    let address     = UILabel()
    let auth        = UILabel()
    let copy        = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.systemBlue.cgColor

        contentView.layer.cornerRadius = 12
        
        addSubview(type)
        addSubview(addressHex)
        addSubview(balance)
        addSubview(auth)
        addSubview(address)
        addSubview(bal)
        addSubview(copy)
        
        type.frame                = CGRect(x: 18, y: 13, width: 250, height: 30)
        type.textColor            = UIColor(named: "colorSet2")
        type.font                 = .boldSystemFont(ofSize: 30)
        
        addressHex.frame          = CGRect(x: 108, y: 35, width: 95, height: 50)
        addressHex.font           = .boldSystemFont(ofSize: 20)
        addressHex.textColor      = .systemGray
        
        address.frame          = CGRect(x: 20, y: 35, width: 100, height: 50)
        address.font           = .systemFont(ofSize: 20)
        address.textColor      = .systemGray2
        address.text           = "address: "
        
        balance.frame       = CGRect(x: 108, y: 65, width: 350, height: 50)
        balance.font        = .boldSystemFont(ofSize: 20)
        balance.textColor   = .systemGray
        
        bal.frame          = CGRect(x: 20, y: 65, width: 100, height: 50)
        bal.font           = .systemFont(ofSize: 20)
        bal.textColor      = .systemGray2
        bal.text           = "balance: "
        
        
        auth.textColor = .white
        auth.layer.cornerRadius = 5
        auth.layer.masksToBounds = true
        auth.textAlignment = .center
        auth.frame = CGRect(x: 280, y: 13, width: 100, height: 30)
        
        copy.layer.cornerRadius = 5
        copy.frame = CGRect(x: 193, y: 41, width: 50, height: 30)
        copy.setImage(UIImage(systemName: "doc.on.doc"), for: .normal)
        copy.tintColor = .systemBlue
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


class specialButtons: UIButton{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTitleColor(.systemGreen, for: .normal)
        backgroundColor = .systemGray6
        titleLabel?.font = .systemFont(ofSize: 15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
