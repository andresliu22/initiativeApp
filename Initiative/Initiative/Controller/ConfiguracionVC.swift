//
//  ConfiguracionVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/23/20.
//

import UIKit
import Alamofire
import SwiftyJSON

class ConfiguracionVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tabChangePass: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabChangePass.frame.size.height - 3, width: tabChangePass.frame.width, height: 3.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tabChangePass.layer.addSublayer(bottomBorder)
        }
    }
    @IBOutlet weak var tabNotifications: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabNotifications.frame.size.height - 3, width: tabNotifications.frame.width, height: 3.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            tabNotifications.layer.addSublayer(bottomBorder)
        }
    }
    
    @IBOutlet weak var currentPassTextField: UITextField!
   
    @IBOutlet weak var newPassTextField: UITextField!
    
    @IBOutlet weak var confirmPassTextField: UITextField!
    
    
    @IBOutlet weak var buttonSavePass: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentPassTextField.delegate = self
        newPassTextField.delegate = self
        confirmPassTextField.delegate = self
        buttonSavePass.addBorders(width: 1)
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
            case currentPassTextField:
                newPassTextField.becomeFirstResponder()
            case newPassTextField:
                confirmPassTextField.becomeFirstResponder()
            case confirmPassTextField:
                confirmPassTextField.resignFirstResponder()
            default:
                confirmPassTextField.resignFirstResponder()
            }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         guard let text = textField.text else { return true }
         let newLength = text.count + string.count - range.length
         return newLength <= 20
    }
    
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
    
    @IBAction func savePassword(_ sender: UIButton) {
        
        guard currentPassTextField.text != "" else {
            showAlert(title: "Error", message: "Ingresar contraseña actual")
            return
        }
        guard newPassTextField.text != "" || confirmPassTextField.text != "" else {
            showAlert(title: "Error", message: "Ingresar nueva contraseña")
            return
        }
        guard newPassTextField.text!.count >= 8 && confirmPassTextField.text!.count >= 8 else {
            showAlert(title: "Error", message: "Nueva contraseña debe tener minimo 8 caracteres")
            return
        }
        guard newPassTextField.text == confirmPassTextField.text else {
            showAlert(title: "Error", message: "Contraseñas no coinciden")
            return
        }
        guard currentPassTextField.text == UserDefaults.standard.string(forKey: "userPass") else {
            showAlert(title: "Error", message: "Contraseña incorrecta")
            return
        }
        guard currentPassTextField.text != newPassTextField.text else {
            showAlert(title: "Error", message: "Elegir una nueva contraseña")
            return
        }
        changePassword()
    }
    
    func changePassword() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["oldPass": currentPassTextField.text!, "newPassword": newPassTextField.text!]
        
        let processing = UIAlertController(title: nil, message: "Procesando...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        processing.view.addSubview(loadingIndicator)
        present(processing, animated: true, completion: nil)
        
        serverManager.serverCallWithHeaders(url: serverManager.changePassURL, params: parameters, method: .put, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                self.dismiss(animated: false, completion: {
                    print("Success")
                    UserDefaults.standard.setValue(self.newPassTextField.text!, forKey: "userPass")
                    self.showAlert(title: "Éxito!", message: "Su contraseña ha sido cambiada satisfactoriamente")
                    self.currentPassTextField.text = ""
                    self.newPassTextField.text = ""
                    self.confirmPassTextField.text = ""
                })
            } else {
                self.dismiss(animated: false, completion: {
                    print("Failure")
                    self.showAlert(title: "Error", message: "Contraseña incorrecta")
                })
            }
        })
    }
    
    @IBAction func goToNotifications(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToNotifications", sender: self)
    }
    
    @IBAction func returnToListado(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
