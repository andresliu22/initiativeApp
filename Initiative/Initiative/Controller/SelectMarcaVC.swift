//
//  SelectMarcaVC.swift
//  Initiative
//
//  Created by Andres Liu on 10/8/20.
//

import UIKit
import SwiftyJSON
import Alamofire

class SelectMarcaVC: UIViewController, UIViewControllerTransitioningDelegate {

    @IBOutlet var collectionView: UICollectionView!
    var listaMarcas: [Marca] = []
    
    var marcaSeleccionada = -1
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        layout.minimumInteritemSpacing = 25
        layout.minimumLineSpacing = 25
        // let height = view.frame.size.height
        let width = view.frame.size.width
        layout.itemSize = CGSize(width: width * 0.9, height: 80)
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        
        validateToken()
        
    }
    
    func validateToken() {
        let serverManager = ServerManager()
        let userToken = UserDefaults.standard.string(forKey: "userToken")!
        let index = userToken.index(userToken.startIndex, offsetBy: 6)
        let parameters : Parameters  = ["userToken": userToken.suffix(from: index)]
        print(userToken.suffix(from: index))
        serverManager.serverCallWithHeaders(url: serverManager.tolenAuthURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard jsonData["isValid"].boolValue else {
                    let alert = UIAlertController(title: "Error", message: "Token ha expirado, ingresar nuevamente", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true)
                    return
                }
                self.getMarcas()
            } else {
                print("Failure")
                let alert = UIAlertController(title: "Error", message: "Token no válido, ingresar nuevamente", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true)
            }
        })
    }
   
    func getMarcas() {
        let serverManager = ServerManager()
        let parameters : Parameters  = [:]
        serverManager.serverCallWithHeadersGET(url: serverManager.marcaURL, params: parameters, method: .get, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    let alert = UIAlertController(title: "Error", message: "No hay marcas registradas en este usuario", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Regresar", style: .default, handler: { (_) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true)
                    return
                }
                for marca in jsonData.arrayValue {
                    let newMarca: Marca = Marca(id: marca["externalcode"].string!, name: marca["name"].string!)
                    self.listaMarcas.append(newMarca)
                }
                self.collectionView.reloadData()
            } else {
                print("Failure")
                let alert = UIAlertController(title: "Error", message: "Time Limit Exceeded", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Reload", style: .default, handler: { _ in self.getMarcas()
                }))
                alert.addAction(UIAlertAction(title: "Return", style: .default, handler: { _ in self.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true)
            }
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        if(!appDelegate.hasAlreadyLaunched) {
            //set hasAlreadyLaunched to false
              appDelegate.sethasAlreadyLaunched()
            //display user agreement license
              self.performSegue(withIdentifier: "goToGuiaMarca", sender: self)
        }
        //self.performSegue(withIdentifier: "goToGuiaMarca", sender: self)
    }
    
//    @IBAction func logoutUser(_ sender: Any) {
//        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
//        self.navigationController?.popToRootViewController(animated: true)
//    }
}

extension SelectMarcaVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listaMarcas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MarcaCollectionViewCell.identifier, for: indexPath) as? MarcaCollectionViewCell {
        
            if marcaSeleccionada == indexPath.row {
                cell.configure(name: listaMarcas[indexPath.row].name, selected: true)
                cell.layer.borderColor = UIColor(rgb: 0x59C7ED).cgColor
            } else {
                cell.configure(name: listaMarcas[indexPath.row].name, selected: false)
                cell.layer.borderColor = UIColor.white.cgColor
            }
            
            cell.layer.borderWidth = 1
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
}

extension SelectMarcaVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //UserDefaults.standard.setValue("C23", forKey: "idBrand")
        UserDefaults.standard.setValue(listaMarcas[indexPath.row].id, forKey: "idBrand")
        print("La marca selecciona es: ")
        print(listaMarcas[indexPath.row].id)
        UserDefaults.standard.setValue(listaMarcas[indexPath.row].name, forKey: "brandName")
        marcaSeleccionada = indexPath.row
        collectionView.reloadData()
        self.performSegue(withIdentifier: "goToListadoReportes", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToListadoReportes" {
            //let presentingVC = segue.source as! SelectMarcaVC
            let destinationVC = segue.destination as! BottomTabBarController
            destinationVC.tabBar.barTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            destinationVC.tabBar.isTranslucent = false
            destinationVC.tabBar.unselectedItemTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            //destinationVC.idBrand = marcaSeleccionada
            destinationVC.transitioningDelegate = self
        }
    }
}

extension SelectMarcaVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width - 40, height: 60)
        
    }
}






