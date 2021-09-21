//
//  ListadoMotivosVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/13/20.
//

import UIKit
import Alamofire
import SwiftyJSON

class ImageViewWithUrl: UIImageView {
    var url: String?
}
class ListadoMotivosVC: UIViewController {

    
    @IBOutlet weak var buttonOrder: UIButton!
    
    
    @IBOutlet weak var motivosTableView: UITableView!
    
    let transparentView = UIView()
    let borderView = UIView()
    let tableView = UITableView()
    var selectedButton = UIButton()
    var imageView = ImageViewWithUrl()
    
    var dataSource = [String]()
    var didSelect = false
    
    //var beforeFilter = ""
    
    var defaultOrder = "Inversion"
    var indexOrder = 0
    let dataLabelOrder = ["totalInversion","totalCurrentScope","totalCurrentImpressions","totalClicks","totalCTR","totalCPC","videoViews10","totalVTR","postReactions","postComments","postShares"]
    
    var motivoSeleccionado = ""
    var motivoId = 0
    var arrayMotivos = [Motivo]()

    var campaignName = ""
    var startDate = ""
    var endDate = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        motivosTableView.dataSource = self
        motivosTableView.delegate = self
        motivosTableView.backgroundColor = UIColor(rgb: 0xF2EFE9)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(ImplementacionFilterCellClass.self, forCellReuseIdentifier: "ImplementacionCell")
        
        buttonOrder.addBorders(width: 1)
        buttonOrder.titleEdgeInsets.left = 10
        buttonOrder.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        getMotivos()
        
    }
    
    func getMotivos() {
    
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!, "campaign": campaignName, "starDate": startDate, "endDate": endDate, "idCurrency": UserDefaults.standard.integer(forKey: "moneda")]
        
        arrayMotivos.removeAll()
        print(campaignName)
        print(startDate)
        print(endDate)
        serverManager.serverCallWithHeaders(url: serverManager.resumenDigitalURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                for categoria in jsonData["categories"].arrayValue {
                    let data = categoria["reportData"]
                    let motivo = Motivo(id: categoria["idCategoryTitle"].int ?? 0, name: categoria["categoryTitle"].string ?? "", imageUrl: categoria["verArteUrl"].string ?? "", activeValue: data[self.dataLabelOrder[self.indexOrder]].float ?? 0.0)
                    self.arrayMotivos.append(motivo)
                }
                self.arrayMotivos.sort { $0.activeValue > $1.activeValue }
                self.motivosTableView.reloadData()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func addTransparentView(searchPlaceholder: String) {
        //let window = UIApplication.shared.keyWindow
        let frames = self.view.frame
        transparentView.frame = self.view.frame
        self.view.addSubview(transparentView)
        self.view.addSubview(borderView)
        self.view.addSubview(tableView)
        
        self.borderView.frame = CGRect(x: frames.minX, y: frames.maxY, width: frames.width, height: 0)
        self.tableView.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
        
        borderView.layer.cornerRadius = 20
        borderView.layer.backgroundColor = #colorLiteral(red: 0.1048603281, green: 0.137150079, blue: 0.1497618556, alpha: 1)
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0.5
            self.borderView.frame = CGRect(x: frames.minX, y: frames.maxY - 330, width: frames.width, height: 360)
            self.tableView.frame = CGRect(x: frames.minX + 30, y: frames.maxY - 300, width: frames.width - 60, height: 300)
        }, completion: nil)
    }
    
    @objc func removeTransparentView() {
        let frames = self.view.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0
            self.borderView.frame = CGRect(x: frames.minX, y: frames.maxY, width: frames.width, height: 0)
            self.tableView.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
            self.imageView.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
            self.tableView.reloadData()
        }, completion: nil)
        
        if didSelect {
            getMotivos()
            didSelect = false
        } else {
            print("No hubo cambio en filtro")
        }
    }
    
    @objc func showImageView() {
        transparentView.frame = self.view.frame
        self.view.addSubview(transparentView)
        self.view.addSubview(imageView)
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        
        let imageUrl = imageView.url!
        if let url = NSURL(string: imageUrl) {
            if let data = NSData(contentsOf: url as URL) {
                imageView.image = UIImage(data: data as Data)
            }
        }
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0.5
            self.imageView.frame = CGRect(x: (self.view.frame.maxX - self.imageView.image!.size.width)/2, y: (self.view.frame.maxY - self.imageView.image!.size.height)/2, width: self.imageView.image!.size.width, height: self.imageView.image!.size.height)
        }, completion: nil)
    }
    
    @IBAction func onClickBtnOrder(_ sender: UIButton) {
        dataSource = ["Inversion", "Alcance", "Impresion", "Clicks", "CTR", "CPC", "Video views", "VTR", "Post reactions", "Post comments", "Post shares"]
        selectedButton = buttonOrder
//        beforeFilter = defaultOrder
//        defaultOrder = ""
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "motivo...")
    }
    
    @IBAction func returnToResumenDigital(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMotivo" {
            let destinationVC = segue.destination as! MotivoVC
            destinationVC.motivoId = motivoId
            destinationVC.vcTitle = motivoSeleccionado
            destinationVC.campaignName = campaignName
            destinationVC.startDate = startDate
            destinationVC.endDate = endDate
        }
    }
}

extension ListadoMotivosVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            return dataSource.count
        } else {
            return arrayMotivos.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImplementacionCell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "Aldine721BT-Roman",
                                      size: 15.0)

        cell.textLabel?.text = dataSource[indexPath.row]
        
        return cell
        } else {
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "MotivosCell")
            
            let eyeImg = UIImage(systemName: "eye")!.withTintColor(.black, renderingMode: .alwaysOriginal)
            cell.imageView!.image = eyeImg
            
            self.imageView.url = arrayMotivos[indexPath.row].imageUrl
            cell.imageView!.isUserInteractionEnabled = true
            let onTap = UITapGestureRecognizer(target: self, action: #selector(showImageView))
            onTap.numberOfTouchesRequired = 1
            onTap.numberOfTapsRequired = 1
            cell.imageView!.addGestureRecognizer(onTap)
            
            cell.backgroundColor = UIColor(rgb: 0xF2EFE9)
            cell.textLabel?.font = UIFont(name: "Aldine721BT-Roman",
                                          size: 15.0)
            
            cell.textLabel?.text = (arrayMotivos[indexPath.row].name)
            
            cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right")!.withTintColor(.black, renderingMode: .alwaysOriginal))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView {
            
            let value: String = dataSource[indexPath.row]
            selectedButton.setTitle(value, for: .normal)
            defaultOrder = value
            indexOrder = indexPath.row
            didSelect = true
            print(value)
            removeTransparentView()
        } else {
            self.motivoSeleccionado = arrayMotivos[indexPath.row].name
            self.motivoId = arrayMotivos[indexPath.row].id
            self.performSegue(withIdentifier: "goToMotivo", sender: self)
        }
    }
    
}

extension ListadoMotivosVC: UITableViewDelegate {
    
}
