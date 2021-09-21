//
//  OlvidarContrasenaVC.swift
//  Initiative
//
//  Created by Andres Liu on 10/26/20.
//

import UIKit
import Alamofire
import SwiftyJSON

class OlvidarContrasenaVC: UIViewController {

    
    @IBOutlet weak var buttonSiguiente: UIButton! {
        didSet {
            buttonSiguiente.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            buttonSiguiente.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var radioButtonEmail: UIImageView!
    
    @IBOutlet weak var correoLabel: UILabel!
    var opcionEscogida = 0
    var correo = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        correoLabel.text = correo
    }
    
    @IBAction func returnToLogin(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendByEmail(_ sender: UIButton) {
        opcionEscogida = 2
        radioButtonEmail.image = UIImage(named: "radioButton-selected")
    }
    @IBAction func nextForgetPass(_ sender: Any) {
        if opcionEscogida == 1 {
            showAlert(title: "Error", message: "Opción no disponible en estos momentos, inténtelo más tarde")
//            performSegue(withIdentifier: "goToOlvidarContrasena2", sender: self)
        } else if opcionEscogida == 2 {
            performSegue(withIdentifier: "goToOlvidarContrasena2", sender: self)
        } else {
            showAlert(title: "Error", message: "Elija una opción")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToOlvidarContrasena2" {
            let destinationVC = segue.destination as! OlvidarContrasenaVC2
            guard opcionEscogida != 1 else {
                return
            }
            destinationVC.correo = self.correo
            destinationVC.modoRecup = "M"
        }
    }
}

class OlvidarContrasenaVC2: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var txtNumber1: UITextField!
    @IBOutlet weak var txtNumber2: UITextField!
    @IBOutlet weak var txtNumber3: UITextField!
    @IBOutlet weak var txtNumber4: UITextField!
    
    @IBOutlet weak var buttonSiguiente2: UIButton! {
        didSet {
            buttonSiguiente2.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            buttonSiguiente2.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var buttonEnviarCodigo: UIButton! {
        didSet {
            let attrs = [
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            let attrString = NSMutableAttributedString.init(string: "Enviar código", attributes: attrs)
            buttonEnviarCodigo.setAttributedTitle(attrString, for: .normal)
        }
    }
    
    var phoneNumber = 0
    var correo = ""
    var modoRecup = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addBorders(txtField: txtNumber1)
        addBorders(txtField: txtNumber2)
        addBorders(txtField: txtNumber3)
        addBorders(txtField: txtNumber4)
        
        txtNumber1.delegate = self
        txtNumber2.delegate = self
        txtNumber3.delegate = self
        txtNumber4.delegate = self
        
        txtNumber1.becomeFirstResponder()
        
        self.hideKeyboardWhenTappedAround()
        
        let serverManager = ServerManager()
        let parameters : Parameters  = ["correo": correo, "modoRecup": modoRecup]
        serverManager.serverCallWithHeadersRecoveryPass(url: serverManager.recoveryPassAppURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                print("Success")
            } else {
                print("Failure")
            }
        })
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if ((textField.text?.count)! < 1) && (string.count > 0) {
            if textField == txtNumber1 {
                txtNumber2.becomeFirstResponder()
            }
            if textField == txtNumber2 {
                txtNumber3.becomeFirstResponder()
            }
            if textField == txtNumber3 {
                txtNumber4.becomeFirstResponder()
            }
            if textField == txtNumber4 {
                txtNumber4.resignFirstResponder()
            }
            textField.text = string
            return false
        } else if ((textField.text?.count)! >= 1) && (string.count == 0) {
            if textField == txtNumber2 {
                txtNumber1.becomeFirstResponder()
            }
            if textField == txtNumber3 {
                txtNumber2.becomeFirstResponder()
            }
            if textField == txtNumber4 {
                txtNumber3.becomeFirstResponder()
            }
            if textField == txtNumber1 {
                txtNumber1.resignFirstResponder()
            }
            textField.text = ""
            return false
        } else if ((textField.text?.count)! >= 1) {
            textField.text = string
            return false
        }
        
        return true
    }
    
    func addBorders(txtField: UITextField){
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = UIColor.black.cgColor
        yourViewBorder.lineDashPattern = [2, 2]
        yourViewBorder.frame = txtField.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(rect: txtField.bounds).cgPath
        txtField.layer.addSublayer(yourViewBorder)
    }
    
    @IBAction func returnToForgetPass1(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func enviarCodigo(_ sender: UIButton) {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["correo": correo, "modoRecup": modoRecup]
        
        let processing = UIAlertController(title: nil, message: "Enviando SMS...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        processing.view.addSubview(loadingIndicator)
        present(processing, animated: true, completion: nil)
        
        serverManager.serverCallWithHeadersRecoveryPass(url: serverManager.recoveryPassAppURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                self.dismiss(animated: false, completion: {
                    print("Success")
                    self.showAlert(title: "Éxito!", message: "El código ha sido enviado correctamente")
                })
            } else {
                self.dismiss(animated: false, completion: {
                    print("Failure")
                    self.showAlert(title: "Error", message: "Ha ocurrido un error en el envio, intentar nuevamente")
                })
            }
        })
    }
    
    @IBAction func nextForgetPass2(_ sender: Any) {
        
        let codigoIngresado = "\(txtNumber1.text!)\(txtNumber2.text!)\(txtNumber3.text!)\(txtNumber4.text!)"
        
        let serverManager = ServerManager()
        let parameters : Parameters  = ["correo": correo, "key": codigoIngresado]
        
        let processing = UIAlertController(title: nil, message: "Verificando...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        processing.view.addSubview(loadingIndicator)
        present(processing, animated: true, completion: nil)
        
        serverManager.serverCallWithHeadersRecoveryPass(url: serverManager.recoveryKeyAppURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                self.dismiss(animated: false, completion: {
                    print("Success")
                    UserDefaults.standard.setValue("Basic \(jsonData["token"].string ?? "")", forKey: "recoveryToken")
                    self.performSegue(withIdentifier: "goToOlvidarContrasena3", sender: self)
                })
            } else {
                self.dismiss(animated: false, completion: {
                    print("Failure")
                    self.showAlert(title: "Error", message: "Código incorrecto")
                })
            }
        })
        
    }
}

class OlvidarContrasenaVC3: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var buttonGuardar: UIButton! {
        didSet {
            buttonGuardar.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            buttonGuardar.layer.borderWidth = 1
        }
    }
    
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var newPassTextField: UITextField!
    
    @IBOutlet weak var passCheck: UIImageView!
    @IBOutlet weak var newPassCheck: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        passTextField.delegate = self
        newPassTextField.delegate = self
        
        self.hideKeyboardWhenTappedAround()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switchBasedNextTextField(textField)
        return true
    }
    
    func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
            case passTextField:
                newPassTextField.becomeFirstResponder()
            case newPassTextField:
                newPassTextField.resignFirstResponder()
            default:
                newPassTextField.resignFirstResponder()
            }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         guard let text = textField.text else { return true }
        if textField == passTextField {
            if textField.text!.count >= 7 {
                passCheck.image = UIImage(named: "ic_correct_code")
            } else {
                passCheck.image = nil
            }
        }
        
        if textField == newPassTextField {
            if textField.text!.count >= 7 {
                newPassCheck.image = UIImage(named: "ic_correct_code")
            } else {
                newPassCheck.image = nil
            }
        }
         let newLength = text.count + string.count - range.length
         return newLength <= 20
    }
    
    @IBAction func returnToForgetPass2(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func guardarContrasena(_ sender: UIButton) {
        
        guard passTextField.text != "" || newPassTextField.text != "" else {
            showAlert(title: "Error", message: "Llenar campos vacios")
            return
        }
        guard passTextField.text!.count >= 8 && newPassTextField.text!.count >= 8 else {
            showAlert(title: "Error", message: "Contraseña debe tener minimo 8 caracteres")
            return
        }
        guard passTextField.text == newPassTextField.text else {
            showAlert(title: "Error", message: "Contraseñas no coinciden")
            return
        }
        
        let serverManager = ServerManager()
        let parameters : Parameters  = ["newPassword": newPassTextField.text!]
        
        let processing = UIAlertController(title: nil, message: "Procesando...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        processing.view.addSubview(loadingIndicator)
        present(processing, animated: true, completion: nil)
        
        serverManager.serverCallWithHeadersRecovery(url: serverManager.changeExternalPassURL, params: parameters, method: .put, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                self.dismiss(animated: false, completion: {
                    print("Success")
                    self.showAlert(title: "Éxito!", message: "Su contraseña ha sido cambiada satisfactoriamente")
                    self.performSegue(withIdentifier: "unwindToLogin", sender: self)
                })
            } else {
                self.dismiss(animated: false, completion: {
                    print("Failure")
                    self.showAlert(title: "Error", message: "Ha habido un error, por favor inténtelo denuevo")
                })
            }
        })
        
    }

}
