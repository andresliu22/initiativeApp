//
//  SideMenuVC.swift
//  Initiative
//
//  Created by Andres Liu on 12/7/20.
//

import UIKit
import Alamofire
import SwiftyJSON

class SideMenuVC: UIViewController {

    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var configButton: UIButton!
    @IBOutlet weak var presetTableView: UITableView!
    
    @IBOutlet weak var presetTitleView: UIView!
    @IBOutlet weak var configView: UIView!
    @IBOutlet weak var monedaView: UIView!
    @IBOutlet weak var contactanosView: UIView!
    @IBOutlet weak var termCondView: UIView!
    @IBOutlet weak var logoutView: UIView!
    
    @IBOutlet weak var buttonSwitchMoneda: UISwitch!
    
    @IBOutlet weak var contact: UILabel!
    var presetName = UserDefaults.standard.array(forKey: "presetName") as? [String] ?? [String]()
    
    var presetArray = UserDefaults.standard.array(forKey: "presetArray") as? [[[Int]]] ?? [[[Int]]]()
    
    var presetSelected = 0
    var monedaId = 2
    
    var info = BusinessInfo(phoneNumber: "", email: "", tyc: "", instagram: "", linkedin: "")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        monedaId = UserDefaults.standard.integer(forKey: "moneda")
        
        if monedaId == 2 {
            buttonSwitchMoneda.isOn = true
        } else {
            buttonSwitchMoneda.isOn = false
        }
        
        SideMenuManager.shared.sideMenuVC = self
        addBottomBorder(viewAd: presetTitleView)
        addBottomBorder(viewAd: configView)
        addBottomBorder(viewAd: monedaView)
        addBottomBorder(viewAd: contactanosView)
        addBottomBorder(viewAd: termCondView)
        addBottomBorder(viewAd: logoutView)
        
        nameLabel.text = UserDefaults.standard.string(forKey: "userFirstName")
        presetTableView.dataSource = self
        presetTableView.delegate = self
        
        getInfo()
    }
    
    func getInfo() {
        let serverManager = ServerManager()
        let parameters : Parameters  = [:]
        serverManager.serverCallWithHeadersGET(url: serverManager.infoURL, params: parameters, method: .get, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                self.info.phoneNumber = jsonData["numcontacto"].string ?? ""
                self.info.email = jsonData["mailcontacto"].string ?? ""
                self.info.tyc = jsonData["tyc"].string ?? ""
                self.info.instagram = jsonData["instagram"].string ?? ""
                self.info.linkedin = jsonData["linkedin"].string ?? ""
                
                self.contact.text = "\(self.info.phoneNumber) / \(self.info.email)"
            } else {
                print("Failure")
            }
        })
    }
    
    func addBottomBorder(viewAd: UIView){
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: 0.0, width: viewAd.frame.width, height: 1.0)
        bottomBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        viewAd.layer.addSublayer(bottomBorder)
    }
    
    @IBAction func goToConfig(_ sender: UIButton) {
        performSegue(withIdentifier: "goToConfig", sender: self)
    }
    @IBAction func switchMoneda(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.setValue(2, forKey: "moneda")
        } else {
            UserDefaults.standard.setValue(1, forKey: "moneda")
        }
    }
    
    @IBAction func onClickLinkedin(_ sender: UIButton) {
        if let url = URL(string: info.linkedin) {
            UIApplication.shared.open(url)
        } else {
            showAlert(title: "Error", message: "No se ha encontrado la página de LinkedIn")
        }
    }
    
    @IBAction func onClickInstagram(_ sender: UIButton) {
        if let url = URL(string: info.instagram) {
            UIApplication.shared.open(url)
        } else {
            showAlert(title: "Error", message: "No se ha encontrado la página de Instagram")
        }
    }
    
    @IBAction func goToTermCond(_ sender: UIButton) {
        performSegue(withIdentifier: "goToTyC", sender: self)
    }
    
    @IBAction func logout(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.set("", forKey: "userToken")
        performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    @objc func accessoryButtonTapped(sender: UIButton){
//        presetName.remove(at: sender.tag)
//        print(presetName)
//        UserDefaults.standard.set(presetName, forKey: "presetName")
//
//        presetArray.remove(at: sender.tag)
//        print(presetArray)
//        UserDefaults.standard.set(presetArray, forKey: "presetArray")
//
//        presetTableView.reloadData()
        presetSelected = sender.tag
        performSegue(withIdentifier: "goToDeletePreset", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDeletePreset" {
            let destinationVC = segue.destination as! DeletePresetVC
            destinationVC.presetSelected = presetSelected
        } else if segue.identifier == "goToTyC" {
            let destinationVC = segue.destination as! TermYCondVC
            destinationVC.tycText = info.tyc
        }
    }
}

extension SideMenuVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presetName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath)
        
        cell.textLabel?.font = UIFont(name: "Aldine721BT-Roman",
                                      size: 15.0)
        cell.textLabel?.text = presetName[indexPath.row]
        
        let xButton = UIButton(type: .custom)
        xButton.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        xButton.addTarget(self, action: #selector(accessoryButtonTapped(sender:)), for: .touchUpInside)
        xButton.setImage(UIImage(systemName: "xmark")!.withTintColor(.darkGray, renderingMode: .alwaysOriginal), for: .normal)
        xButton.contentMode = .scaleAspectFit
        xButton.tag = indexPath.row
        cell.accessoryView = xButton as UIView
        
        //cell.accessoryView = UIImageView(image: UIImage(systemName: "xmark")!.withTintColor(.darkGray, renderingMode: .alwaysOriginal))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let inversion = storyboard!.instantiateViewController(withIdentifier: "InversionVC") as! InversionVC
        inversion.arrayVacio = false
        inversion.arrayYear = self.presetArray[indexPath.row][0]
        inversion.arrayMonth = self.presetArray[indexPath.row][1]
        inversion.arrayMedia = self.presetArray[indexPath.row][2]
        inversion.arrayProvider = self.presetArray[indexPath.row][3]
        inversion.arrayCampaign = self.presetArray[indexPath.row][4]
        self.navigationController?.pushViewController(inversion, animated: true)
    }
    
}

extension SideMenuVC: UITableViewDelegate {
    
}
