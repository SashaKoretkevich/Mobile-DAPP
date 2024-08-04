import Web3
import UIKit
import Web3PromiseKit
import Web3ContractABI



class addViewController: UIViewController, UITextFieldDelegate {

    let inputAddress = UITextField(frame: CGRect(x: 50, y: 80, width: 300, height: 50))
    let inputType = UITextField(frame: CGRect(x: 50, y: 180, width: 300, height: 50))
    
    let inputAddrTitle = UILabel(frame: CGRect(x: 50, y: 30, width: 250, height: 50))
    let inputTypeTitle = UILabel(frame: CGRect(x: 50, y: 130, width: 250, height: 50))
    
    let acceptChanges = UIButton(frame: CGRect(x: 50, y: 270, width: 300, height: 50))
    let errorShow         = UILabel(frame: CGRect(x: 100, y: 310, width: 200, height: 50))

    override func viewDidLoad() {
        super.viewDidLoad()
        acceptChanges.setTitle("Add new device", for: .normal)
        acceptChanges.addTarget(self, action: #selector(buttonTextField), for: .touchUpInside)
        acceptChanges.tintColor = .white
        acceptChanges.backgroundColor = .systemGreen
        acceptChanges.layer.cornerRadius = 10
        
        inputAddrTitle.text = "Device's address"
        inputTypeTitle.text = "Device's type"
        
        inputAddrTitle.textColor = .systemGreen
        inputTypeTitle.textColor = .systemGreen
        
        inputAddress.placeholder = "Input address"
        inputAddress.borderStyle = .roundedRect
        inputAddress.backgroundColor = UIColor(named: "colorSet")
        
        inputType.placeholder = "Input type"
        inputType.borderStyle = .roundedRect
        inputType.backgroundColor = UIColor(named: "colorSet")
                
        view.addSubview(inputAddress)
        view.addSubview(inputType)
        
        view.addSubview(inputAddrTitle)
        view.addSubview(inputTypeTitle)
        
        view.addSubview(acceptChanges)
        
        inputAddress.delegate = self
        inputType.delegate = self
        
        view.backgroundColor = .systemGray6
    }
    
    private func textFieldAddr(_ textField: UITextField) -> String {
         return inputAddress.text!
     }
    
    private func textFieldType(_ textField: UITextField) -> String {
         return inputType.text!
     }
    
    @objc func buttonTextField(sender: UIButton!) {

            if inputAddress.text?.isEmpty == true{
                inputAddress.attributedPlaceholder = NSAttributedString(string: "Enter the address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            if inputType.text?.isEmpty == true{
                inputType.attributedPlaceholder = NSAttributedString(string: "Enter the type", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
            }
            if inputAddress.text?.isEmpty == false && inputType.text?.isEmpty == false{
                do{
                    try EthereumAddress(hex: inputAddress.text!, eip55: true)
                    loading()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.addDevice(self.inputAddress.text!, self.inputType.text!)
                        self.dismiss(animated: true, completion: nil)
                        }
                    errorShow.text = ""
                }
                catch{
                    print("Error: \(error)")
                    errorShow.text = "Wrong address! Try again!"
                    errorShow.textColor = .systemRed
                    view.addSubview(errorShow)
                }
                }
        }
    
    func loading(){
            let circle = UIActivityIndicatorView(style: .large)
            circle.color = UIColor.systemGray2
            circle.frame = CGRect(x: 150, y: 300, width: 100, height: 100)
            circle.startAnimating()
            view.addSubview(circle)
    }
                
    func addDevice(_ deviceAddress: String, _ deviceType: String){
        
        let contract = HomeViewController.contract()
        let deviceAddress = try! EthereumAddress(hex: deviceAddress, eip55: true)
        let deviceType = deviceType
        let nonce = try! HomeViewController.web3.eth.getTransactionCount(address: HomeViewController.walletAddress, block: HomeViewController.tag).wait()
        let call = callFun(input: "addDevice", contract: contract)!(deviceAddress, deviceType)
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
    
    
    func callFun(input: String, contract: DynamicContract) -> ((ABIEncodable...) -> SolidityInvocation)?{
         let result: ((ABIEncodable...) -> SolidityInvocation)? = contract[input]
         return result
     }
}
