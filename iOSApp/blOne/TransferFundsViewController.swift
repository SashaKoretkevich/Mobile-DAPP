import Web3
import UIKit
import Web3PromiseKit
import Web3ContractABI

class TransferFundsViewController: UIViewController, UITextFieldDelegate {
    let inputFunds = UITextField(frame: CGRect(x: 30, y: 240, width: 330, height: 50))
    let titl       = UILabel(frame: CGRect(x: 30, y: 0, width: 300, height: 100))
    let balance    = UILabel(frame: CGRect(x: 30, y: 105, width: 330, height: 110))
    let transfer   = specialButtons(frame: CGRect(x: 30, y: 700, width: 330, height: 50))
    let errorType  = UILabel(frame: CGRect(x: 30, y: 300, width: 200, height: 50))
    let noCertify   = UILabel(frame: CGRect(x: 30, y: 650, width: 370, height: 50))
    private let indexCell: Int
    private let devices: [Devices]
    
    
    init (indexCell: Int, devices: [Devices])
    {
        self.indexCell = indexCell
        self.devices = devices
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputFunds.placeholder = "Input funds"
        inputFunds.borderStyle = .roundedRect
        inputFunds.backgroundColor = UIColor(named: "colorSet")
        
        titl.textColor = UIColor(named: "colorSet2")
        titl.text      = "How much you want to transfer?"
        titl.font      = .boldSystemFont(ofSize: 30)
        titl.numberOfLines = 2
        
        balance.textColor       = .white
        balance.text            = " " + HomeViewController.devBalanceRound(balance: Double(HomeViewController.getBalance(address: HomeViewController.walletAddress))) + " Sepolia ETH"
        balance.font            = .boldSystemFont(ofSize: 30)
        balance.backgroundColor = .systemGreen
        balance.layer.cornerRadius = 20.0
        balance.layer.masksToBounds = true
        
        transfer.setTitle("Transfer", for: .normal)
        transfer.layer.cornerRadius = 10
        transfer.titleLabel?.font = .systemFont(ofSize: 20)
        
        errorType.textColor = .systemRed
        
        if devices[indexCell].certified == false{
            noCertify.text = "No access to transfer funds - certify first"
            noCertify.textColor = .systemRed
        }
        else{
            transfer.addTarget(self, action: #selector(transf), for: .touchUpInside)
        }
        
        view.addSubview(inputFunds)
        view.addSubview(titl)
        view.addSubview(balance)
        view.addSubview(transfer)
        view.addSubview(errorType)
        view.addSubview(noCertify)
        
        inputFunds.delegate = self
        view.backgroundColor = UIColor(named: "colorSet")
    }
    
    private func textFieldFunds(_ textField: UITextField) -> String {
         return inputFunds.text!
     }
    
    @objc func transf(sender: specialButtons!){
        if inputFunds.text?.isEmpty == true{
            inputFunds.attributedPlaceholder = NSAttributedString(string: "Enter the sum", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        else{
            let balance = try! HomeViewController.web3.eth.getBalance(address: HomeViewController.walletAddress, block: HomeViewController.tag).wait()
            let amount = BigUInt(((inputFunds.text! as NSString).doubleValue) * Double(pow(10.0, 18.0)))
            if inputFunds.text!.contains(",") == false && balance.quantity > amount && amount != 0{
                loading()
                transferFunds(amount)
                }
            else if inputFunds.text!.contains(",") == true{
                    errorType.text = "Wrong input"
                }
            else{
                errorType.text = "Error occured"
            }
        }
    }
    
    func loading(){
        let circle = UIActivityIndicatorView(style: .large)
        circle.color = UIColor.systemGray2
        circle.frame = CGRect(x: 150, y: 600, width: 100, height: 100)
        circle.startAnimating()
        view.addSubview(circle)
    }
    func callFun(input: String, contract: DynamicContract) -> ((ABIEncodable...) -> SolidityInvocation)?{
         let result: ((ABIEncodable...) -> SolidityInvocation)? = contract[input]
         return result
     }
    
    private func transferFunds(_ money: BigUInt){
        let contract = HomeViewController.contract()
        let moneyEth = EthereumQuantity(quantity: money)
        
        let nonce = try! HomeViewController.web3.eth.getTransactionCount(address: HomeViewController.walletAddress, block: HomeViewController.tag).wait()
        let call = callFun(input: "transferFunds", contract: contract)!(devices[indexCell].address)
        let gasPrice = try! HomeViewController.web3.eth.gasPrice().wait()
        guard let transaction = call.createTransaction(nonce: nonce, gasPrice: gasPrice, maxFeePerGas: gasPrice, maxPriorityFeePerGas: 500000, gasLimit: 500000, from: HomeViewController.walletAddress, value: moneyEth, accessList: [:], transactionType: .eip1559)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.dismiss(animated: true, completion: nil)
                }
        }.catch { error in
            print(error)
            self.errorType.text = "Wrong amount"
        }
    }
    
}
