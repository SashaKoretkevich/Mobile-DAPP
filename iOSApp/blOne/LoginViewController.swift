import UIKit
import Web3

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    let inputAddress = UITextField(frame: CGRect(x: 50, y: 365, width: 300, height: 50))
    let login = UILabel(frame: CGRect(x: 160, y: 280, width: 100, height: 50))
    let welcome = UILabel(frame: CGRect(x: 120, y: 315, width: 200, height: 50))
    let enter = UIButton(frame: CGRect(x: 50, y: 435, width: 300, height: 50))
    var res   = UILabel(frame: CGRect(x: 50, y: 475, width: 350, height: 50))

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appIc = UIImageView(frame: CGRect(x: 90, y: 80, width: 200, height: 200))
        appIc.image = UIImage(named: "blockchain-1.png")
        
        self.view.backgroundColor = UIColor(named: "colorSet")
        welcome.text = "Log in to your account"
        welcome.textColor = .systemGray2
        
        login.text = "Login"
        login.textColor = UIColor(named: "colorSet2")
        login.font = .boldSystemFont(ofSize: 30)
        
        inputAddress.placeholder = "Input address"
        inputAddress.borderStyle = .roundedRect
        inputAddress.backgroundColor = UIColor(named: "colorSet")
        inputAddress.delegate = self
        
        enter.setTitle("Login", for: .normal)
        enter.setTitleColor(.white, for: .normal)
        enter.backgroundColor = .systemGreen
        enter.layer.cornerRadius = 10
        enter.addTarget(self, action: #selector(checkAdmin), for: .touchUpInside)
        
        view.addSubview(inputAddress)
        view.addSubview(enter)
        view.addSubview(res)
        view.addSubview(appIc)
        view.addSubview(welcome)
        view.addSubview(login)
    }
    
    private func textFieldAddr(_ textField: UITextField) -> String {
         return inputAddress.text!
     }
    
    @objc func checkAdmin(sender: UIButton!){
        if inputAddress.text?.isEmpty == true{
            inputAddress.attributedPlaceholder = NSAttributedString(string: "Enter the address", attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
        }
        else{
            do {
                let input =  try EthereumAddress(hex: inputAddress.text!, eip55: true)
                if input == HomeViewController.walletAddress{
                    res.text = "Access granted!"
                    res.textColor = .systemGreen
                    let hvc = HomeViewController()
                    let navi = UINavigationController(rootViewController: hvc)
                    navi.modalPresentationStyle = .fullScreen
                    present(navi, animated: true, completion: nil)
                }
                else{
                    res.text = "Wrong address, you are not an admin!"
                    res.textColor = .systemRed
                }
            } catch {
                print("Error: \(error)")
                res.text = "Wrong address, error appeared!"
                res.textColor = .systemRed
            }
        }
    }
    
}
