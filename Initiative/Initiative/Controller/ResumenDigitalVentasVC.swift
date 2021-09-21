//
//  ResumenDigitalVentasVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/16/20.
//

import UIKit
import Alamofire
import SwiftyJSON

class ResumenDigitalVentasVC: UIViewController {

    
    @IBOutlet weak var buttonPerformance: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: buttonPerformance.frame.size.height - 2, width: buttonPerformance.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            buttonPerformance.layer.addSublayer(bottomBorder)
        }
    }
    
    @IBOutlet weak var buttonVentas: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: buttonVentas.frame.size.height - 2, width: buttonVentas.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            buttonVentas.layer.addSublayer(bottomBorder)
        }
    }
    
    @IBOutlet weak var buttonCampaign: UIButton!
    
    @IBOutlet weak var lineView: UIView!
    
    @IBOutlet weak var campaignCollectionView: UICollectionView!
    
    var arrayVentas = [RDVenta]()
    var arrayCampaign = [String]()
    
    let transparentView = UIView()
    let borderView = UIView()
    let inBetweenView = UIView()
    let searchBar = UISearchBar()
    let tableView = UITableView()
    var selectedButton = UIButton()
    
    var dataSource = [FilterBody]()
    var dataSearch = [FilterBody]()
    var searching = false
    var didSelect = false
    
    var arrayBeforeFilter = [String]()
    var campaignList = [FilterBody]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.searchBar.delegate = self
        
        buttonCampaign.addBorders(width: 1)
        buttonCampaign.titleEdgeInsets.left = 10
        buttonCampaign.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        let topLayer = CALayer()
        topLayer.frame = CGRect(x: 0, y: 30, width: self.view.frame.width - 40, height: 1)

        let topBorder = CAShapeLayer()
        topBorder.strokeColor = UIColor.black.cgColor
        topBorder.lineWidth = 1
        topBorder.lineDashPattern = [2, 2]
        topBorder.frame = topLayer.bounds
        topBorder.fillColor = nil
        topBorder.path = UIBezierPath(rect: topLayer.bounds).cgPath
        
        topLayer.addSublayer(topBorder)
        self.lineView.layer.addSublayer(topLayer)
        
        campaignCollectionView.dataSource = self
        campaignCollectionView.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ImplementacionFilterCellClass.self, forCellReuseIdentifier: "ImplementacionCell")
        
        getCampaign()
    }
    
    public func getCampaign(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.resumenDigitalSalesCampaignsURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay datos de campañas")
                    return
                }
                var count = 1
                for campaign in jsonData["campaignList"].arrayValue {
                    let isContained = self.campaignList.contains { $0.id == campaign["idCampaign"].int! }
                    
                    if !isContained {
                        let newCampaign: FilterBody = FilterBody(id: campaign["idCampaign"].int!, name: campaign["name"].string!)
                        self.campaignList.append(newCampaign)
                        if count == 1 {
                            self.arrayCampaign.append(newCampaign.name)
                            self.buttonCampaign.setTitle(newCampaign.name, for: .normal)
                            count += 1
                        }
                    }
                }
                self.getVentas()
            } else {
                print("Failure")
            }
        })
    }
    
    func getVentas() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!, "campaign": arrayCampaign[0], "idCurrency": UserDefaults.standard.integer(forKey: "moneda")]
        
        arrayVentas.removeAll()
        
        serverManager.serverCallWithHeaders(url: serverManager.resumenDigitalVentasURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                    
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }

                for categoria in jsonData["categories"].arrayValue {
                    var venta = RDVenta(titulo: "\(categoria["categoryTitle"].string!) \(self.arrayCampaign[0])", source: categoria["source"].string ?? "", valorVisitas: 0.0, valorVisitasEsperado: 0.0, valorSesiones: 0.0, valorSesionesEsperado: 0.0, valorConversaciones: 0.0, valorConversacionesEsperado: 0.0)
                    for statistic in categoria["statistics"].arrayValue {
                        if statistic["statTitle"].string!.caseInsensitiveCompare("Visitas") == .orderedSame {
                            venta.valorVisitas = statistic["currentValue"].float ?? 0
                            venta.valorVisitasEsperado = statistic["expectedValue"].float ?? 0
                        } else if statistic["statTitle"].string!.caseInsensitiveCompare("Sesiones") == .orderedSame  {
                            venta.valorSesiones = statistic["currentValue"].float ?? 0
                            venta.valorSesionesEsperado = statistic["expectedValue"].float ?? 0
                        } else if statistic["statTitle"].string!.caseInsensitiveCompare("Conversiones") == .orderedSame  {
                            venta.valorConversaciones = statistic["currentValue"].float ?? 0
                            venta.valorConversacionesEsperado = statistic["expectedValue"].float ?? 0
                        }
                    }
                    print(venta)
                    self.arrayVentas.append(venta)
                }
                
                self.campaignCollectionView.reloadData()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func addTransparentView(searchPlaceholder: String) {
        
        let frames = self.view.frame
        transparentView.frame = self.view.frame
        self.view.addSubview(transparentView)
        self.view.addSubview(borderView)
        self.view.addSubview(searchBar)
        self.view.addSubview(inBetweenView)
        self.view.addSubview(tableView)
        
        self.borderView.frame = CGRect(x: frames.minX, y: frames.maxY, width: frames.width, height: 0)
        self.searchBar.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
        self.inBetweenView.frame = CGRect(x: frames.minX, y: frames.maxY, width: frames.width - 60, height: 0)
        self.tableView.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
        
        
        let searchTextField: UITextField? = searchBar.value(forKey: "searchField") as? UITextField
            if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
                let attributeDict = [NSAttributedString.Key.foregroundColor: UIColor.black]
                searchTextField!.attributedPlaceholder = NSAttributedString(string: "Buscar \(searchPlaceholder)", attributes: attributeDict)
            }
        
        borderView.layer.cornerRadius = 20
        borderView.layer.backgroundColor = #colorLiteral(red: 0.1048603281, green: 0.137150079, blue: 0.1497618556, alpha: 1)
        searchBar.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        inBetweenView.layer.backgroundColor = #colorLiteral(red: 0.1048603281, green: 0.137150079, blue: 0.1497618556, alpha: 1)
        
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        tableView.reloadData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removeTransparentView))
        
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0.5
            self.borderView.frame = CGRect(x: frames.minX, y: frames.maxY - 400, width: frames.width, height: 420)
            self.searchBar.frame = CGRect(x: frames.minX + 30, y: frames.maxY - 370, width: frames.width - 60, height: 50)
            self.inBetweenView.frame = CGRect(x: frames.minX + 30, y: frames.maxY - 320, width: frames.width - 60, height: 20)
            self.tableView.frame = CGRect(x: frames.minX + 30, y: frames.maxY - 300, width: frames.width - 60, height: 300)
        }, completion: nil)
    }
    
    @objc func removeTransparentView() {
        let frames = self.view.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0
            self.borderView.frame = CGRect(x: frames.minX, y: frames.maxY, width: frames.width, height: 0)
            self.searchBar.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
            self.inBetweenView.frame = CGRect(x: frames.minX, y: frames.maxY, width: frames.width - 60, height: 0)
            self.tableView.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
            self.searchBar.text = ""
            self.searching = false
            self.tableView.reloadData()
            self.searchBar.resignFirstResponder()
        }, completion: nil)
        
        if didSelect {
            getVentas()
            didSelect = false
        } else {
            if arrayCampaign.isEmpty {
                arrayCampaign = arrayBeforeFilter
            }
            print("No hubo cambio en filtro")
        }
    }
    
    @IBAction func onClickBtnCampaign(_ sender: UIButton) {
        dataSource = campaignList
        selectedButton = buttonCampaign
        arrayBeforeFilter = arrayCampaign
        arrayCampaign.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "campaña...")
    }
    @IBAction func goToPerformance(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func returnToListado(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension ResumenDigitalVentasVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayVentas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VentaCell", for: indexPath) as? RDVentasCollectionViewCell {
            
//            cell.contentView.layer.cornerRadius = 10
//            cell.contentView.layer.masksToBounds = true
//            cell.contentView.layer.borderWidth = 1
//            cell.contentView.layer.borderColor = UIColor.clear.cgColor
            
            cell.contentView.layer.shadowColor = UIColor.black.cgColor
            cell.contentView.layer.shadowRadius = 3.0
            cell.contentView.layer.shadowOpacity = 0.5
            cell.contentView.layer.masksToBounds = false
            cell.contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
            cell.contentView.layer.backgroundColor = UIColor.clear.cgColor
//            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath
            
            cell.listarVenta(titulo: arrayVentas[indexPath.row].titulo, source: arrayVentas[indexPath.row].source, cantidadVisitas: arrayVentas[indexPath.row].valorVisitas, cantidadVisitasE: arrayVentas[indexPath.row].valorVisitasEsperado, cantidadSesiones: arrayVentas[indexPath.row].valorSesiones, cantidadSesionesE: arrayVentas[indexPath.row].valorSesionesEsperado, cantidadConversaciones: arrayVentas[indexPath.row].valorConversaciones, cantidadConversacionesE: arrayVentas[indexPath.row].valorConversacionesEsperado)
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    
}

extension ResumenDigitalVentasVC: UICollectionViewDelegate {
    
}


extension ResumenDigitalVentasVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return dataSearch.count
        } else {
            return dataSource.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImplementacionCell", for: indexPath)
        cell.textLabel?.font = UIFont(name: "Aldine721BT-Roman",
                                      size: 15.0)
        if searching {
            cell.textLabel?.text = dataSearch[indexPath.row].name
        } else {
            cell.textLabel?.text = dataSource[indexPath.row].name
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView {
            var arrayValues = [String]()

            switch (selectedButton) {
                case buttonCampaign:
                    arrayValues = arrayCampaign
                default:
                    arrayValues = arrayCampaign
            }

            var value: String = ""

            if searching {
                value = dataSearch[indexPath.row].name
            } else {
                value = dataSource[indexPath.row].name
            }

            arrayValues.append(value)
            selectedButton.setTitle(value, for: .normal)

            switch (selectedButton) {
                case buttonCampaign:
                    arrayCampaign = arrayValues
                default:
                    arrayCampaign = arrayValues
            }
            didSelect = true
            print(arrayValues)
            removeTransparentView()
        }
    }
    
}

extension ResumenDigitalVentasVC: UITableViewDelegate {
}

extension ResumenDigitalVentasVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSearch = dataSource.filter({$0.name.uppercased().contains(searchText.uppercased())})
        if searchText != "" {
            searching = true
        } else {
            searching = false
        }
        tableView.reloadData()
    }
}

extension ResumenDigitalVentasVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = self.view.frame.width - 40
        let cellHeight = cellWidth / 3 + 140
        return CGSize(width: cellWidth, height: cellHeight)
        
        
    }
}
