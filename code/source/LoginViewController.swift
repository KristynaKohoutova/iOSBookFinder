import Foundation
import FirebaseAuth

class LoginViewController: UIViewController{
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // loging user with the email and password
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error{
                    print(e)
                }else{
                    self.performSegue(withIdentifier: "LoginToMenu", sender: self)
                }
              
            }
        }
    }
}

