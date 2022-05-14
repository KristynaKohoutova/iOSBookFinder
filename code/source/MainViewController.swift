import UIKit
import NurAPIBluetooth
import FirebaseAuth

class MainViewController: UIViewController {
    let myNurApi = NurApiCreate()

    let myDB_Manager = DB_Manager.sharedInstance
    
    @IBOutlet weak var readerName: UILabel!
    
    // logging out the user
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    // general setting when the view loads, creating the singleton instance of Bluetooth object
    override func viewDidLoad() {
        
        var resultValues : [[String]] = []
        resultValues = myDB_Manager.read()
        for value in resultValues{
            print(value)
        }
        
        super.viewDidLoad()

        guard let reader = Bluetooth.sharedInstance().currentReader else {
            self.readerName.text = "no reader connected"
            return
        }

        self.readerName.text = reader.name ?? reader.identifier.uuidString
    }
}
