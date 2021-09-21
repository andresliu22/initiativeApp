//
//  ResumenDigitalPerformanceVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/11/20.
//

import UIKit
import Alamofire
import SwiftyJSON

class ResumenDigitalPerformanceVC: UIViewController {

    
    @IBOutlet weak var tabPerformance: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabPerformance.frame.size.height - 2, width: tabPerformance.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tabPerformance.layer.addSublayer(bottomBorder)
        }
    }
    @IBOutlet weak var tabVentas: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabVentas.frame.size.height - 2, width: tabVentas.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            tabVentas.layer.addSublayer(bottomBorder)
        }
    }
   
    @IBOutlet weak var buttonCampaign: UIButton!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var buttonMotivos: UIButton!
    
    @IBOutlet weak var inversionView: UIView!
    @IBOutlet weak var inversionTotal: UILabel!

    @IBOutlet weak var inversionAlcance: UILabel!
    
    @IBOutlet weak var inversionAlcanceEsperado: UILabel!
    @IBOutlet weak var inversionImpresiones: UILabel!
    
    @IBOutlet weak var inversionImpresionesCPM: UILabel!
    @IBOutlet weak var clickView: UIView!
    @IBOutlet weak var clicksTotal: UILabel!
    
    @IBOutlet weak var ctrView: UIView!
    @IBOutlet weak var ctrTotal: UILabel!
    
    @IBOutlet weak var cpcView: UIView!
    @IBOutlet weak var cpcTotal: UILabel!
    
    @IBOutlet weak var clicksLinkView: UIView!
    @IBOutlet weak var clicksLinkTotal: UILabel!
    
    @IBOutlet weak var ctrLinkView: UIView!
    @IBOutlet weak var ctrLinkTotal: UILabel!
    
    @IBOutlet weak var cpcLinkView: UIView!
    @IBOutlet weak var cpcLinkTotal: UILabel!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoTotal: UILabel!
    
    @IBOutlet weak var vtrView: UIView!
    @IBOutlet weak var vtrTotal: UILabel!
    
    @IBOutlet weak var cpcSView: UIView!
    @IBOutlet weak var cpcSTotal: UILabel!
    
    @IBOutlet weak var reactionsView: UIView!
    @IBOutlet weak var reactionsTotal: UILabel!
    
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var commentsTotal: UILabel!
    
    @IBOutlet weak var sharesView: UIView!
    @IBOutlet weak var sharesTotal: UILabel!
    
    let transparentView = UIView()
    let borderView = UIView()
    let inBetweenView = UIView()
    let searchBar = UISearchBar()
    let tableView = UITableView()
    var selectedButton = UIButton()
    var imageView = UIImageView()
    
    var dataSource = [FilterBody]()
    var dataSearch = [FilterBody]()
    var searching = false
    var didSelect = false
    
    var arrayBeforeFilter = [String]()
    
    var campaignList = [FilterBody]()
    var arrayCampaign = [String]()
    

    @IBOutlet weak var alcanceGauge: UIView!
    
    @IBOutlet weak var impresionGauge: UIView!
    
    var alcanceGaugeGraph = GaugeView(frame: CGRect(x: 0, y: 0, width: 120, height: 60))
    var impresionGaugeGraph = GaugeView(frame: CGRect(x: 0, y: 0, width: 120, height: 60))
    var gaugeValue = 0
    
    
    @IBOutlet weak var startDateTxt: UITextField!
    
    @IBOutlet weak var finishDateTxt: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(ImplementacionFilterCellClass.self, forCellReuseIdentifier: "ImplementacionCell")
        
        buttonCampaign.addBorders(width: 1)
        buttonMotivos.addBorders(width: 2)
        
        buttonCampaign.titleEdgeInsets.left = 10
        buttonCampaign.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        inversionView.layer.cornerRadius = 10
        clickView.layer.cornerRadius = 10
        ctrView.layer.cornerRadius = 10
        cpcView.layer.cornerRadius = 10
        clicksLinkView.layer.cornerRadius = 10
        ctrLinkView.layer.cornerRadius = 10
        cpcLinkView.layer.cornerRadius = 10
        videoView.layer.cornerRadius = 10
        vtrView.layer.cornerRadius = 10
        cpcSView.layer.cornerRadius = 10
        reactionsView.layer.cornerRadius = 10
        commentsView.layer.cornerRadius = 10
        sharesView.layer.cornerRadius = 10
        
        alcanceGaugeGraph.value = gaugeValue
        alcanceGaugeGraph.backgroundColor = .clear
        alcanceGauge.addSubview(alcanceGaugeGraph)
        
        impresionGaugeGraph.value = gaugeValue
        impresionGaugeGraph.backgroundColor = .clear
        impresionGauge.addSubview(impresionGaugeGraph)
        
        startDateTxt.layer.borderWidth = 1
        startDateTxt.layer.borderColor = UIColor.black.cgColor
        startDateTxt.setLeftPaddingPoints(5.0)
        startDateTxt.datePicker(target: self,
                                          doneAction: #selector(startDoneAction),
                                          cancelAction: #selector(startCancelAction),
                                          datePickerMode: .date)
        finishDateTxt.layer.borderWidth = 1
        finishDateTxt.layer.borderColor = UIColor.black.cgColor
        finishDateTxt.setLeftPaddingPoints(5.0)
        finishDateTxt.datePicker(target: self,
                                          doneAction: #selector(finishDoneAction),
                                          cancelAction: #selector(finishCancelAction),
                                          datePickerMode: .date)
        
        addLineBorder()
        getDate()
    }
    
    func addLineBorder() {
        let topLayer = CALayer()
        topLayer.frame = CGRect(x: 30.0, y: 15, width: self.view.frame.width - 60, height: 1)

        let topBorder = CAShapeLayer()
        topBorder.strokeColor = UIColor.black.cgColor
        topBorder.lineWidth = 1
        topBorder.lineDashPattern = [2, 2]
        topBorder.frame = topLayer.bounds
        topBorder.fillColor = nil
        topBorder.path = UIBezierPath(rect: topLayer.bounds).cgPath
        
        topLayer.addSublayer(topBorder)
        contentView.layer.addSublayer(topLayer)
    }
    
    func getDate() {
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        
        var stringDay = ""
        var stringMonth = ""
        if day < 10 {
            stringDay = "0\(day)"
        } else {
            stringDay = "\(day)"
        }
        
        if month < 10 {
            stringMonth = "0\(month)"
        } else {
            stringMonth = "\(month)"
        }
        startDateTxt.text = "01/\(stringMonth)/\(year)"
        finishDateTxt.text = "\(stringDay)/\(stringMonth)/\(year)"
        
        getCampaign()
    }
    
    public func getCampaign(){
        //var campaignList = [FilterBody]()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.resumenDigitalPerformanceCampaignsURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
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
                self.getPerformance()
            } else {
                print("Failure")
            }
        })
    }
    
    func getPerformance() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!, "campaign": arrayCampaign[0], "starDate": startDateTxt.text!, "endDate": finishDateTxt.text!, "idCurrency": UserDefaults.standard.integer(forKey: "moneda")]
        
        serverManager.serverCallWithHeaders(url: serverManager.resumenDigitalURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                print(jsonData)
                if self.arrayCampaign.contains(jsonData["title"].string!) {
                    let data = jsonData["reportData"]
                    print(data["totalClicks"])
                    let motivo = Motive(totalInversion: data["totalInversion"].float ?? 0.0, totalCurrentScope: data["totalCurrentScope"].float ?? 0.0, totalExpectedScope: data["totalExpectedScope"].float ?? 1.0, totalCurrentImpressions: data["totalCurrentImpressions"].float ?? 0.0,  totalExpectedImpressions: data["totalExpectedImpressions"].float ?? 1.0, totalCPMImpressions: data["totalCPMImpressions"].float ?? 0.0, totalClicks: data["totalClicks"].float ?? 0.0, totalLinkClicks: data["totalLinkClicks"].float ?? 0.0, totalCTR: data["totalCTR"].float ?? 0.0, totalLinkCTR: data["totalLinkCTR"].float ?? 0.0, totalCPC: data["totalCPC"].float ?? 0.0, totalLinkCPC: data["totalLinkCPC"].float ?? 0.0, videoViews10: data["videoViews10"].float ?? 0.0, totalVTR: data["totalVTR"].float ?? 0.0, totalCPC10: data["totalCPC10"].float ?? 0.0, postReactions: data["postReactions"].float ?? 0.0, postComments: data["postComments"].float ?? 0.0, postShares: data["postShares"].float ?? 0.0)
                    
                    self.inversionTotal.text = "$ \(motivo.totalInversion)"
                    
                    if motivo.totalCurrentScope < 1000000 {
                        self.inversionAlcance.text = "$ \(String(format: "%.2f", motivo.totalCurrentScope / 1000))K"
                    } else {
                        self.inversionAlcance.text = "$ \(String(format: "%.2f", motivo.totalCurrentScope / 1000000))MM"
                    }
                    
                    if motivo.totalExpectedScope <= 0 {
                        self.inversionAlcanceEsperado.text = "100%"
                    } else {
                        if motivo.totalCurrentScope / motivo.totalExpectedScope > 100 {
                            self.inversionAlcanceEsperado.text = "100%"
                        } else {
                            self.inversionAlcanceEsperado.text = "\(motivo.totalCurrentScope / motivo.totalExpectedScope * 100)%"
                        }
                    }
                    
                    if motivo.totalCurrentImpressions < 1000000 {
                        self.inversionImpresiones.text = "$ \(String(format: "%.2f", motivo.totalCurrentImpressions / 1000))K"
                    } else {
                        self.inversionImpresiones.text = "$ \(String(format: "%.2f", motivo.totalCurrentImpressions / 1000000))MM"
                    }
                    
                    self.inversionImpresionesCPM.text = "$ \(motivo.totalCPMImpressions) CPM"
                    self.clicksTotal.text = "\(String(format: "%.2f",(motivo.totalClicks/1000)))K"
                    self.ctrTotal.text = "\(motivo.totalCTR)%"
                    self.cpcTotal.text = "$ \(motivo.totalCPC)"
                    self.clicksLinkTotal.text = "$ \(String(format: "%.2f", motivo.totalLinkClicks/1000))K"
                    self.ctrLinkTotal.text = "\(motivo.totalLinkCTR)%"
                    self.cpcLinkTotal.text = "$ \(motivo.totalLinkCPC)"
                    self.videoTotal.text = "\(String(format: "%.2f",motivo.videoViews10/1000))K"
                    self.vtrTotal.text = "\(motivo.totalVTR)%"
                    self.cpcSTotal.text = "$ \(motivo.totalCPC10)"
                    self.reactionsTotal.text = "\(String(format: "%.2f",motivo.postReactions/1000))K"
                    self.commentsTotal.text = "\(String(format: "%.2f",motivo.postComments/1000))K"
                    self.sharesTotal.text = "\(String(format: "%.2f",motivo.postShares/1000))K"
                    
                    if motivo.totalExpectedScope <= motivo.totalCurrentScope {
                        self.alcanceGaugeGraph.value = 100
                    } else {
                        self.alcanceGaugeGraph.value = Int(motivo.totalCurrentScope/motivo.totalExpectedScope * 100)
                    }
                    
                    self.alcanceGaugeGraph.valueArea = self.alcanceGaugeGraph.value
                    
                    if motivo.totalExpectedImpressions <= motivo.totalCurrentImpressions {
                        self.impresionGaugeGraph.value = 100
                    } else {
                        self.impresionGaugeGraph.value = Int(motivo.totalCurrentImpressions/motivo.totalExpectedImpressions * 100)
                    }
                    
                    self.impresionGaugeGraph.valueArea = self.impresionGaugeGraph.value
                    
                    self.alcanceGaugeGraph.setNeedsDisplay()
                    self.impresionGaugeGraph.setNeedsDisplay()
                }
                
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
            getPerformance()
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
    
    @objc func startCancelAction() {
        self.startDateTxt.resignFirstResponder()
    }

    @objc func startDoneAction() {
        if let datePickerView = self.startDateTxt.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: datePickerView.date)
            self.startDateTxt.text = dateString
            
            print(datePickerView.date)
            print(dateString)
            
            self.startDateTxt.resignFirstResponder()
        }
    }
    
    @objc func finishCancelAction() {
        self.finishDateTxt.resignFirstResponder()
    }

    @objc func finishDoneAction() {
        if let datePickerView = self.finishDateTxt.inputView as? UIDatePicker {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: datePickerView.date)
            self.finishDateTxt.text = dateString
            
            print(datePickerView.date)
            print(dateString)
            
            self.finishDateTxt.resignFirstResponder()
            self.getPerformance()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToListadoMotivos" {
            //let presentingVC = segue.source as! SelectMarcaVC
            let destinationVC = segue.destination as! ListadoMotivosVC
            destinationVC.campaignName = arrayCampaign[0]
            destinationVC.startDate = startDateTxt.text!
            destinationVC.endDate = finishDateTxt.text!
            
        }
    }
    
    @IBAction func onClickBtnMotivos(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToListadoMotivos", sender: self)
    }
    
    
    
    
    @IBAction func returnToReportList(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func goToVentas(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToVentas", sender: self)
    }
    
}

extension ResumenDigitalPerformanceVC: UITableViewDataSource {
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

extension ResumenDigitalPerformanceVC: UITableViewDelegate {
    
}

extension ResumenDigitalPerformanceVC: UISearchBarDelegate {
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

extension UITextField {
    func datePicker<T>(target: T,
                       doneAction: Selector,
                       cancelAction: Selector,
                       datePickerMode: UIDatePicker.Mode = .date) {
        let screenWidth = UIScreen.main.bounds.width
        
        func buttonItem(withSystemItemStyle style: UIBarButtonItem.SystemItem) -> UIBarButtonItem {
            let buttonTarget = style == .flexibleSpace ? nil : target
            let action: Selector? = {
                switch style {
                case .cancel:
                    return cancelAction
                case .done:
                    return doneAction
                default:
                    return nil
                }
            }()
            
            let barButtonItem = UIBarButtonItem(barButtonSystemItem: style,
                                                target: buttonTarget,
                                                action: action)
            
            return barButtonItem
        }
        
        let datePicker = UIDatePicker(frame: CGRect(x: 0,
                                                    y: 0,
                                                    width: screenWidth,
                                                    height: 216))
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.datePickerMode = datePickerMode
        self.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0,
                                              y: 0,
                                              width: screenWidth,
                                              height: 44))
        toolBar.setItems([buttonItem(withSystemItemStyle: .cancel),
                          buttonItem(withSystemItemStyle: .flexibleSpace),
                          buttonItem(withSystemItemStyle: .done)],
                         animated: true)
        self.inputAccessoryView = toolBar
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

