//
//  PresetVC.swift
//  Initiative
//
//  Created by Andres Liu on 12/14/20.
//

import UIKit

class PresetVC: UIViewController {
    
    @IBOutlet weak var savePresetView: UIView!
    @IBOutlet weak var savePresetTitleView: UIView!
    @IBOutlet weak var presetNameTxt: UITextField!
    @IBOutlet weak var buttonSavePreset: UIButton!
    
    var preset = [[Int]]()
    override func viewDidLoad() {
        super.viewDidLoad()

        savePresetView.layer.cornerRadius = 10.0
        savePresetView.layer.masksToBounds = true
        buttonSavePreset.addBorders(width: 2)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         guard let text = textField.text else { return true }
         let newLength = text.count + string.count - range.length
         return newLength <= 20
    }
    
    @IBAction func closePresetView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePreset(_ sender: UIButton) {
        guard presetNameTxt.text != "" else {
            showAlert(title: "Error", message: "Escribe un nombre")
            return
        }
        
        var presetName = UserDefaults.standard.array(forKey: "presetName") as? [String] ?? [String]()
        presetName.append(presetNameTxt.text!)
        UserDefaults.standard.set(presetName, forKey: "presetName")
        
        var presetArray = UserDefaults.standard.array(forKey: "presetArray") as? [[[Int]]] ?? [[[Int]]]()
        presetArray.append(preset)
        UserDefaults.standard.set(presetArray, forKey: "presetArray")
        
        let alert = UIAlertController(title: "Éxito", message: "El preset ha sido creado", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true)
        
    
    }
}

