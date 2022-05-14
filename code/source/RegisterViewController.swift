import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController{
   
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    // registering new user with the email and password
    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in if let e = error{
                    print(e)
                }else{
                    self.performSegue(withIdentifier: "RegisterToMenu", sender: self)
                }
            }
        }
    }
    
}
