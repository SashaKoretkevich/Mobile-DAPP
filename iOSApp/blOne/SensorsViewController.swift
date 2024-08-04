import UIKit
import Web3
import BigInt

class SensorsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let allSensors = UITableView()
    
    let address: EthereumAddress
    
    var ultraData: [BigUInt] = []
    var potData: [BigUInt]   = []
    
    var dataTimer: Timer?
    
    
    init (address: EthereumAddress)
    {
        self.address = address
        super.init(nibName: nil, bundle: nil)
        ultraData = AdcellViewController.getUltra(address)
        potData = AdcellViewController.getPot(address)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "All sensors data"
        view.addSubview(allSensors)
        allSensors.dataSource = self
        allSensors.delegate = self
        allSensors.register(adCell.self, forCellReuseIdentifier: "cell")
        allSensors.frame = view.bounds
        allSensors.rowHeight  = 100
        
        dataTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.reload()
        }
        
    }
    
    func reload(){
        allSensors.reloadData()
    }
    deinit {
        dataTimer?.invalidate()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        ultraData = AdcellViewController.getUltra(address)
        potData = AdcellViewController.getPot(address)
        if (potData.isEmpty && ultraData.isEmpty){
            return 1
        }
        else{
            return max(potData.count, ultraData.count)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! adCell
        if (potData.isEmpty){
            cell.pot.text   = "No Data"
        }
        else{
            if potData.count - 1 >= indexPath.row{
                cell.pot.text = String(potData[indexPath.row]) + " V"
                if (potData[indexPath.row] < 70){
                    cell.pot.textColor = .systemGreen
                }
                else if (potData[indexPath.row] < 85){
                    cell.pot.textColor = .systemYellow
                }
                else{
                    cell.pot.textColor = .systemRed
                }
            }
            else{
                cell.pot.text = "No Data"
            }
            
        }
        if (ultraData.isEmpty){
            cell.ultra.text = "No Data"
        }
        else{
            if ultraData.count - 1 >= indexPath.row{
                cell.ultra.text = String(ultraData[indexPath.row]) + " cm"
            }
            else{
                cell.ultra.text = "No Data"
            }
        }
        return cell
    }
}
