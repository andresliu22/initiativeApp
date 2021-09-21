//
//  NoticiasVC.swift
//  Initiative
//
//  Created by Andres Liu on 10/25/20.
//

import UIKit
import SwiftyJSON
import Alamofire
import SideMenu

class NoticiasVC: UIViewController {

    @IBOutlet weak var noticiasCollectionView: UICollectionView!

    @IBOutlet weak var topBarView: UIView! {
        didSet {
            let topBorder = CALayer()
            topBorder.frame = CGRect(x: 0.0, y: topBarView.frame.size.height - 0.5, width: topBarView.frame.width, height: 0.5)
            topBorder.backgroundColor = UIColor(rgb: 0x1B2326).cgColor
            topBarView.layer.addSublayer(topBorder)
        }
    }
    
    let diaSemana = ["Domingo", "Lunes", "Martes", "Miercoles", "Jueves", "Viernes", "Sabado"]
    let mes = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    @IBOutlet weak var fechaHoy: UILabel! {
        didSet {
            let date = Date()
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: date)
            let day = calendar.component(.day, from: date)
            let month = calendar.component(.month, from: date)
            let year = calendar.component(.year, from: date)
            
            fechaHoy.text = "\(diaSemana[weekday - 1 ]) \(day) de \(mes[month - 1]) del \(year)"
        }
    }
    
    var listaNoticias: [Noticia] = []
    
    @IBOutlet weak var buttonMarcas: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        noticiasCollectionView.dataSource = self
        noticiasCollectionView.delegate = self
        
        let userType = UserDefaults.standard.string(forKey: "userType")
        if userType == "HOLDING" {
            buttonMarcas.isHidden = false
        } else {
            buttonMarcas.isHidden = true
        }
        
        getNoticias()
        
    }
    
    func getNoticias() {
        let serverManager = ServerManager()
        let parameters : Parameters  = [:]
        serverManager.serverCallWithHeadersGET(url: serverManager.noticiaURL, params: parameters, method: .get, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                //print("Success")
                //print(jsonData)
                for noticia in jsonData.arrayValue {
                    let newNoticia: Noticia = Noticia(titulo: noticia["title"].string!, descripcion: noticia["description"].string!, linkURL: noticia["subtitle"].string!, imageURL: noticia["url_image"].string!)
                    self.listaNoticias.append(newNoticia)
                }
                self.noticiasCollectionView.reloadData()
            } else {
                print("Failure")
            }
        })
    }
    
    
    @IBAction func regresarMarcas(_ sender: Any) {
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

extension NoticiasVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listaNoticias.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoticiaCell", for: indexPath) as? NoticiasCollectionViewCell {
            
            cell.layer.cornerRadius = 10
            cell.listarNoticia(imagenURL: listaNoticias[indexPath.row].imageURL, titulo: listaNoticias[indexPath.row].titulo, fecha: listaNoticias[indexPath.row].descripcion)
            
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
}

extension NoticiasVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let url = URL(string: listaNoticias[indexPath.row].linkURL) {
            UIApplication.shared.open(url)
        }
    }
    
}

extension NoticiasVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.width - 40, height: (self.view.frame.width - 40) / 3 * 2)
        
    }
}
extension UIImage {
  func resizeImage(targetSize: CGSize) -> UIImage {
    let size = self.size
    let widthRatio = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
  }
}
