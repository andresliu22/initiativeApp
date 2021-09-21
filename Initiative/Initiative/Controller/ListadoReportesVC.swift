//
//  ListadoReportesVC.swift
//  Initiative
//
//  Created by Andres Liu on 10/15/20.
//

import UIKit
import SwiftyJSON
import Alamofire
import SideMenu

class ListadoReportesVC: UIViewController {
    
    @IBOutlet weak var reportesCollectionView: UICollectionView!
    @IBOutlet weak var topBarView: UIView! {
        didSet {
            let topBorder = CALayer()
            topBorder.frame = CGRect(x: 0.0, y: topBarView.frame.size.height - 0.5, width: topBarView.frame.width, height: 0.5)
            topBorder.backgroundColor = UIColor(rgb: 0x1B2326).cgColor
            topBarView.layer.addSublayer(topBorder)
        }
    }
    var idBrand: Int = 0
    var listaReportes: [Reporte] = []
    let reportesImg: [String] = ["INVERSION_POSITIVO", "ESTADO_DE_CUENTA_POSITIVO", "FACTURACION_POSITIVO", "PERFORMANCE_DIGITAL_POSITIVO", "REPORTE_DE_MERCADO_POSITIVO", "IMPLEMENTACION_DIGITAL_POSITIVO"]
    
    // ["PERFORMANCE_DIGITAL_POSITIVO", "REPORTE_DE_MERCADO_POSITIVO", "INVERSION_POSITIVO", "IMPLEMENTACION_DIGITAL_POSITIVO", "FACTURACION_POSITIVO", "ESTADO_DE_CUENTA_POSITIVO"]
    
    let reportesName: [String] = ["INVERSIÓN", "ESTADO DE CUENTA", "FACTURACIÓN", "RESUMEN DIGITAL", "REPORTE DE MERCADO", "IMPLEMENTACIÓN DE CAMPAÑAS"]
    
    
    @IBOutlet weak var buttonMarcas: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportesCollectionView.delegate = self
        reportesCollectionView.dataSource = self
        
        let userType = UserDefaults.standard.string(forKey: "userType")
        if userType == "HOLDING" {
            buttonMarcas.isHidden = false
        } else {
            buttonMarcas.isHidden = true
        }
        
        //getInfoUsuario()
        getReportes()
    }
    
    func getInfoUsuario() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["userToken": UserDefaults.standard.string(forKey: "userToken")!]
        serverManager.serverCallWithHeaders(url: serverManager.myProfileURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                print("Success")
                
                UserDefaults.standard.setValue("\(jsonData["firstName"].string ?? "")", forKey: "userFirstName")
                
            } else {
                print("Failure")
            }
        })
    }
    func getReportes() {
        
        for i in 0..<6 {
            let newReporte: Reporte = Reporte(titulo: self.reportesName[i], descripcion: "")
            self.listaReportes.append(newReporte)
        }
        
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.reporteURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                print("Success")
                
                for reporte in jsonData["infoBrand"].arrayValue {
                    let index = self.listaReportes.firstIndex(where: { $0.titulo.capitalized == reporte["title"].string!.capitalized })
                    self.listaReportes[Int(index!)].descripcion = reporte["description"].string!
                }
                
                self.reportesCollectionView.reloadData()
            } else {
                print("Failure")
            }
        })
    }
    @IBAction func regresarMarcas(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func logoutUser(_ sender: UIButton) {
        let menu = storyboard!.instantiateViewController(withIdentifier: "LeftMenu") as! SideMenuNavigationController
        menu.presentationStyle = .menuSlideIn
        menu.presentationStyle.presentingEndAlpha = 0.5
        menu.presentationStyle.onTopShadowOpacity = 1
        present(menu, animated: true, completion: nil)
        
    }
    
}

extension ListadoReportesVC: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listaReportes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listadoReportes", for: indexPath) as? ReporteCollectionViewCell {
        
            cell.listarReporte(title: listaReportes[indexPath.row].titulo, logo: UIImage(named: reportesImg[indexPath.row])!, fecha: listaReportes[indexPath.row].descripcion)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: self.view.frame.width * 0.45, height: self.view.frame.width * 0.8)
//    }
}

extension ListadoReportesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch (indexPath.row) {
            case 0:
                self.performSegue(withIdentifier: "goToInversion", sender: self)
                break
            case 1:
                self.performSegue(withIdentifier: "goToEstadoDeCuenta", sender: self)
                break
            case 2:
                self.performSegue(withIdentifier: "goToFacturacion", sender: self)
                break
            case 3:
                self.performSegue(withIdentifier: "goToResumenDigital", sender: self)
                break
            case 4:
                self.performSegue(withIdentifier: "goToReporteMercado", sender: self)
                break
            case 5:
                self.performSegue(withIdentifier: "goToImplementacion", sender: self)
                break
            default:
                self.performSegue(withIdentifier: "goToInversion", sender: self)
                break
        }
    }
    
}

extension ListadoReportesVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width / 2 - 20, height: 200)
        
    }
}

