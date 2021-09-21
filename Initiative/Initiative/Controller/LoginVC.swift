//
//  ViewController.swift
//  Initiative
//
//  Created by Andres Liu on 10/8/20.
//

import UIKit
import SwiftyJSON
import Alamofire
import SwiftJWT

extension UIButton {
    func addBorders (width: CGFloat) {
        let button = self
        button.layer.borderWidth = width
        button.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    }
}

extension UIViewController {
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func validateEntryData(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Regresar", style: .default, handler: { (_) in
            self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true)
    }
}

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userInputText: UITextField!
    @IBOutlet weak var passInputText: UITextField!
    @IBOutlet weak var buttonIngresarOutlet: UIButton! {
        didSet {
            buttonIngresarOutlet.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            buttonIngresarOutlet.layer.borderWidth = 1
        }
    }
    @IBOutlet weak var olvidarContrasenaOutlet: UIButton! {
        didSet {
            let attrs = [
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            let attrString = NSMutableAttributedString.init(string: "¿Olvidaste tu contraseña?", attributes: attrs)
            olvidarContrasenaOutlet.setAttributedTitle(attrString, for: .normal)
        }
    }
    
    var userToken: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userInputText.delegate = self
        passInputText.delegate = self
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if UserDefaults.standard.bool(forKey: "isUserLoggedIn") == true {
            //navigateToMarcas(animation: false)
            //self.performSegue(withIdentifier: "goToMarcas", sender: self)
            getInfoUsuario()
        } 
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switchBasedNextTextField(textField)
        return true
    }
    
    func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
            case userInputText:
                passInputText.becomeFirstResponder()
            case passInputText:
                passInputText.resignFirstResponder()
                userLogin(buttonIngresarOutlet)
            default:
                passInputText.resignFirstResponder()
            }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         guard let text = textField.text else { return true }
         let newLength = text.count + string.count - range.length
         return newLength <= 30
    }
    
    @IBAction func userLogin(_ sender: UIButton) {
        
        if (userInputText.text != "") {
            let validEmail = isValidEmail(userInputText.text!)
            if validEmail {
                if (passInputText.text != ""){
                    
                    var jwtToken: String = ""
                    let myHeader = Header()
                    //let myClaims = MyClaims(user: "admin@holinsys.pe", password: "T3rr4N0v4Pr1m3")
                    struct MyUser: Claims {
                        let user: String
                        let password: String
                    }
                    let myUser = MyUser(user: userInputText.text!, password: passInputText.text!)
                    var myJWT = JWT(header: myHeader, claims: myUser)
                    let urlPath = Bundle.main.url(forResource: "privateKey", withExtension: "key")!

                    do {
                        let privateKey: Data = try Data(contentsOf: urlPath)
                        let jwtSigner = JWTSigner.hs256(key: privateKey)
                        let signedJWT = try myJWT.sign(using: jwtSigner)
                        jwtToken = signedJWT
                    } catch {
                        print("Error")
                    }
                    
                    let serverManager = ServerManager()
                    let parameters : Parameters  = ["id_token": jwtToken]
                    let loggingIn = UIAlertController(title: nil, message: "Iniciando sesión...", preferredStyle: .alert)

                    let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                    loadingIndicator.hidesWhenStopped = true
                    loadingIndicator.style = UIActivityIndicatorView.Style.medium
                    loadingIndicator.startAnimating();

                    loggingIn.view.addSubview(loadingIndicator)
                    present(loggingIn, animated: true, completion: nil)
                    
                    UserDefaults.standard.setValue(2, forKey: "moneda")
                    UserDefaults.standard.setValue("123", forKey: "userToken")
                    
                    serverManager.serverCallWithHeaders(url: serverManager.loginURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
                        
                        if intCheck == 1 {
                            self.dismiss(animated: false, completion: {
                                print("Success")
                                self.userToken = jwtToken
                                print(jwtToken)
                                UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                                UserDefaults.standard.setValue("Basic \(jsonData["jwt"])", forKey: "userToken")
                                UserDefaults.standard.setValue(self.passInputText.text!, forKey: "userPass")
//                                UserDefaults.standard.setValue("Basic ZXlKMGVYQWlPaUpLVjFRaUxDSmhiR2NpT2lKSVV6STFOaUo5LmV5SjBiMnRsYmlJNklqSTFZelV4TWpnMVl6Um1PR1F6WXpBeU56UmtZekl5WlRZNFpEUTRaREkyTW1aa01ERm1aVFEwTlROak16Tm1OVGhoWmpka1ptTTFPVEV3WXprME5UZGpNVFkzTldVMllXRXpaakk0TUdZellqWTJaREEzTTJSa01EUmhJaXdpYVdSVmMzVmhjbWx2SWpvaU1TSXNJbWxrVW05c0lqb2lNU0o5LkEzYmdpcUpTcTdKVkFyemVURlVnbGNvTTFLcmtKQVFKVEVGYU5VYmRBbXM=", forKey: "userToken")
                                
                                self.getInfoUsuario()
                                //self.performSegue(withIdentifier: "goToMarcas", sender: self)
                                //self.navigateToMarca(animation: true)
                            })
                            
                        } else {
                            self.dismiss(animated: false, completion: {
                                print("Failure")
                                let alert = UIAlertController(title: "Error", message: "Usuario y/o contraseña incorrecta", preferredStyle: .alert)
                                
                                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                                self.present(alert, animated: true)
                            })
                        }
                    })
                    
                } else {
                    showAlert(title: "Error", message: "Ingresar contraseña")
                }
            } else {
                showAlert(title: "Error", message: "Ingresar correo válido")
            }
        } else {
            showAlert(title: "Error", message: "Ingresar correo")
        }

    }
    
    func getInfoUsuario() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["userToken": UserDefaults.standard.string(forKey: "userToken")!]
        serverManager.serverCallWithHeaders(url: serverManager.myProfileURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                print("Success")
                
                UserDefaults.standard.setValue("\(jsonData["firstName"].string ?? "")", forKey: "userFirstName")
                UserDefaults.standard.setValue(jsonData["userType"].string!.uppercased(), forKey: "userType")
                
                if jsonData["userType"].string!.uppercased() == "HOLDING" {
                    self.performSegue(withIdentifier: "goToMarcas", sender: self)
                } else {
                    self.getMarca()
                }
            } else {
                print("Failure")
            }
        })
    }
    
    func getMarca() {
        let serverManager = ServerManager()
        let parameters : Parameters  = [:]
        serverManager.serverCallWithHeadersGET(url: serverManager.marcaURL, params: parameters, method: .get, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                for marca in jsonData.arrayValue {
                    //let newMarca: Marca = Marca(id: marca["externalcode"].string!, name: marca["name"].string!)
                    UserDefaults.standard.setValue(marca["externalcode"].string!, forKey: "idBrand")
                    UserDefaults.standard.setValue(marca["name"].string!, forKey: "brandName")
                    self.performSegue(withIdentifier: "fromLoginToListado", sender: self)
                }
            } else {
                print("Failure")
                let alert = UIAlertController(title: "Error", message: "Time Limit Exceeded", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { _ in self.getMarca()
                }))
                alert.addAction(UIAlertAction(title: "Return", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true)
            }
        })
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func olvidarContrasena(_ sender: UIButton) {
        if userInputText.text == "" {
            let alert = UIAlertController(title: "Error", message: "Ingresar correo", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            let validEmail = isValidEmail(userInputText.text!)
            if validEmail {
                performSegue(withIdentifier: "goToOlvidarContrasena", sender: self)
            } else {
                let alert = UIAlertController(title: "Error", message: "Ingresar un correo válido", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMarcas" {
            let presentingVC = segue.source as! LoginVC
            presentingVC.passInputText.text = ""
        } else if segue.identifier == "goToOlvidarContrasena" {
            let destinationVC = segue.destination as! OlvidarContrasenaVC
            destinationVC.correo = userInputText.text!
        }
    }
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {}
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

// MARK: - Dismiss Keyboard
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


//extension UIScrollView {
//
//    func scrollToView(view:UIView, animated: Bool) {
//        if let origin = view.superview {
//            // Get the Y position of your child view
//            let childStartPoint = origin.convert(view.frame.origin, to: self)
//            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
//            self.scrollRectToVisible(CGRect(x:0, y:childStartPoint.y,width: 1,height: self.frame.height), animated: animated)
//        }
//    }
//
//    func scrollToTop() {
//        let topOffset = CGPoint(x: 0, y: -50)
//        setContentOffset(topOffset, animated: true)
//    }
//
//    func scrollToBottom() {
//        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
//        if(bottomOffset.y > 0) {
//            setContentOffset(bottomOffset, animated: true)
//        }
//    }
//}
