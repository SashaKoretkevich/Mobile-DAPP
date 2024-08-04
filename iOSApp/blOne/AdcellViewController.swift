import Web3
import Foundation
import UIKit
import Web3PromiseKit
import Web3ContractABI

class AdcellViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    let indexCell: Int
    var devices: [Devices] = HomeViewController.getAllDevices()
    
    var ultraData: [BigUInt] = []
    var potData: [BigUInt]   = []
    
    var dataTimer: Timer?
    var dataTimer2: Timer?
    var seconds = 30
    
    let remove   = specialButtons()
    let transfer = specialButtons()
    let certify  = specialButtons()
    let balance  = UILabel(frame: CGRect(x: 30, y: 160, width: 330, height: 80))
    let bal      = UILabel(frame: CGRect(x: 32, y: 90, width: 400, height: 80))
    let mes      = UILabel(frame: CGRect(x: 30, y: 300, width: 200, height: 80))
    
    let sensors   = UITableView()
    
    init (indexCell: Int)
    {
        self.indexCell = indexCell
        super.init(nibName: nil, bundle: nil)
        ultraData = AdcellViewController.getUltra(devices[indexCell].address)
        potData = AdcellViewController.getPot(devices[indexCell].address)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            setUpButton()
            setUpBalance()
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        remove.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        remove.setTitle(" Remove", for: .normal)
        remove.tintColor = .systemGreen
        remove.addTarget(self, action: #selector(removeDev), for: .touchUpInside)
        
        transfer.setImage(UIImage(systemName: "dollarsign.circle"), for: .normal)
        transfer.setTitle(" Transfer", for: .normal)
        transfer.tintColor = .systemGreen
        transfer.addTarget(self, action: #selector(transferFunds), for: .touchUpInside)

        certify.setImage(UIImage(systemName: "checkmark"), for: .normal)
        certify.tintColor = .systemGreen
        certify.addTarget(self, action: #selector(cer), for: .touchUpInside)

        
        balance.font  = .boldSystemFont(ofSize: 30)
        balance.textColor = .white
        balance.backgroundColor = .systemGreen
        balance.layer.cornerRadius = 5
        balance.layer.masksToBounds = true


        bal.textColor = UIColor(named: "colorSet2")
        bal.font      = .boldSystemFont(ofSize: 35)
        bal.text      = "Balance"
        
        title = "Device №" + String(indexCell + 1)
        view.backgroundColor = UIColor(named: "colorSet")
        
        sensors.rowHeight  = 100
        sensors.frame = CGRect(x: 30, y: 340, width: 330, height: 100)
        sensors.dataSource = self
        sensors.delegate = self
        
        setUpBalance()
        setUpButton()
        remove.frame = CGRect(x: 250, y: 260, width: 110, height: 60)
        transfer.frame = CGRect(x: 140, y: 260, width: 110, height: 60)
        certify.frame = CGRect(x: 30, y: 260, width: 110, height: 60)
        
        view.addSubview(sensors)
        view.addSubview(bal)
        view.addSubview(balance)
        view.addSubview(certify)
        view.addSubview(transfer)
        view.addSubview(remove)
        view.addSubview(remove)

            
        sensors.register(adCell.self, forCellReuseIdentifier: "cell")
        
        
        dataTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.reload()
            }
        }
    
    func setUpBalance(){
        balance.text = " " + HomeViewController.devBalanceRound(balance: (Double(devices[indexCell].balance))) + " Sepolia ETH"
    }
    func setUpButton(){
        if devices[indexCell].certified == false{
            certify.setTitle(" Certify", for: .normal)
        }
        else{
            certify.setTitle(" Uncertify", for: .normal)
        }
    }
    
    func reload(){
        sensors.reloadData()
    }
    deinit {
        dataTimer?.invalidate()
    }
    
     static func getPot(_ deviceAddress: EthereumAddress)-> [BigUInt]{
        let contract = HomeViewController.contract()
        let call  = try! HomeViewController.callFun(input: "getMetrics", contract: contract)!(deviceAddress, 1).call().wait()
        let array: [BigUInt] = call[""]! as! [BigUInt]
        return array
    }
    
    
    static func getUltra(_ deviceAddress: EthereumAddress) -> [BigUInt]{
       let contract = HomeViewController.contract()
       let call     = try! HomeViewController.callFun(input: "getMetrics", contract: contract)!(deviceAddress, 2).call().wait()
       let array: [BigUInt] = call[""]! as! [BigUInt]
       return array
   }
    
    func callFun(input: String, contract: DynamicContract) -> ((ABIEncodable...) -> SolidityInvocation)?{
         let result: ((ABIEncodable...) -> SolidityInvocation)? = contract[input]
         return result
     }
    
    @objc func removeDev(_ sender: specialButtons!) {
        
        let alert = UIAlertController(title: "Remove device", message: "Do you want to remove device?", preferredStyle: UIAlertController.Style.alert)
        
        let cont = UIAlertAction(title: "Continue", style: UIAlertAction.Style.default){ _ in
            let contract = HomeViewController.contract()
            let nonce = try! HomeViewController.web3.eth.getTransactionCount(address: HomeViewController.walletAddress, block: HomeViewController.tag).wait()
            let call = self.callFun(input: "removeDevice", contract: contract)!(self.devices[self.indexCell].address)
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
                self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(cont)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func transferFunds(_ sender: specialButtons!) {
        let navi = UINavigationController(rootViewController: TransferFundsViewController(indexCell: indexCell, devices: devices))
        navigationController?.present(navi, animated: true)
    }
    
    @objc func cer(_ sender: specialButtons!){
        if devices[indexCell].certified == false{
            HomeViewController.certify(devices[indexCell].address, devices[indexCell].certified)
        }
        else{
            let alert = UIAlertController(title: "Uncertify device", message: "Do you want to uncertify device?", preferredStyle: UIAlertController.Style.alert)
            let cont = UIAlertAction(title: "Continue", style: UIAlertAction.Style.default){ _ in
                HomeViewController.certify(self.devices[self.indexCell].address, self.devices[self.indexCell].certified)
            }
            alert.addAction(cont)
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}


extension AdcellViewController{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        ultraData = AdcellViewController.getUltra(devices[indexCell].address)
        potData = AdcellViewController.getPot(devices[indexCell].address)
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! adCell
        if (!potData.isEmpty){
                cell.pot.text = String(potData[potData.count - 1]) + " V"
            if (potData[potData.count - 1] < 70){
                    cell.pot.textColor = .systemGreen
            }
            else if (potData[potData.count - 1] < 85){
                    cell.pot.textColor = .systemYellow
            }
            else{
                    cell.pot.textColor = .systemRed
            }
        }
        else{
            cell.pot.text = "No Data"
        }
        if (!ultraData.isEmpty){
            cell.ultra.text = String(ultraData[ultraData.count - 1]) + " cm"
        }
        else{
            cell.ultra.text = "No Data"
        }
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.navigationController?.pushViewController(SensorsViewController(address: devices[indexCell].address), animated: true)
    }
}

class adCell: UITableViewCell{
    
    let ultra = UILabel()
    let pot   = UILabel()
    let uLab  = UILabel()
    let pLab  = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layer.masksToBounds = false
        layer.shadowColor = UIColor.systemBlue.cgColor
        contentView.layer.cornerRadius = 12
        
        addSubview(ultra)
        addSubview(pot)
        addSubview(uLab)
        addSubview(pLab)
        
        ultra.frame = CGRect(x: 120, y: 20, width: 150, height: 30)
        ultra.font = .boldSystemFont(ofSize: 20)
        
        pot.frame = CGRect(x: 155, y: 60, width: 150, height: 30)
        pot.font  = .boldSystemFont(ofSize: 20)
        
        uLab.frame = CGRect(x: 20, y: 20, width: 200, height: 30)
        uLab.textColor = .systemGray2
        uLab.text = "Ultrasonic: "
        uLab.font  = .systemFont(ofSize: 20)
        
        pLab.frame = CGRect(x: 20, y: 60, width: 200, height: 30)
        pLab.textColor = .systemGray2
        pLab.text  = "Potentiometer: "
        pLab.font  = .systemFont(ofSize: 20)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


