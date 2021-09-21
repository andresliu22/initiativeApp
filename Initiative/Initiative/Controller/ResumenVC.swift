//
//  ResumenVC.swift
//  Initiative
//
//  Created by Andres Liu on 12/7/20.
//

import UIKit
import SideMenu
import Alamofire
import SwiftyJSON

class ResumenVC: UIViewController {

    @IBOutlet weak var topBarView: UIView! {
        didSet {
            let topBorder = CALayer()
            topBorder.frame = CGRect(x: 0.0, y: topBarView.frame.size.height - 0.5, width: topBarView.frame.width, height: 0.5)
            topBorder.backgroundColor = UIColor(rgb: 0x1B2326).cgColor
            topBarView.layer.addSublayer(topBorder)
        }
    }
    
    @IBOutlet weak var view1: UIView!
    
    @IBOutlet weak var longGadgetView1: UIView!
    @IBOutlet weak var longBorderView1: UIView!
    @IBOutlet weak var longGadgetTitle1: UILabel!
    @IBOutlet weak var longGadgetDesc1: UILabel!
    
    @IBOutlet weak var longGadget1Sub1: UILabel!
    @IBOutlet weak var longGadget1Desc1: UILabel!
    @IBOutlet weak var longGadget1Sub2: UILabel!
    @IBOutlet weak var longGadget1Desc2: UILabel!
    @IBOutlet weak var longGadget1Sub3: UILabel!
    @IBOutlet weak var longGadget1Desc3: UILabel!
    
    @IBOutlet weak var leftBorderView1: UIView!
    @IBOutlet weak var leftAddButton1: UIButton!
    @IBOutlet weak var leftGadgetView1: UIView!
    @IBOutlet weak var leftGadgetTitle1: UILabel!
    @IBOutlet weak var leftGadgetDesc1: UILabel!
    @IBOutlet weak var leftGadget1Sub1: UILabel!
    @IBOutlet weak var leftGadget1Desc1: UILabel!
    @IBOutlet weak var leftGadget1Sub2: UILabel!
    @IBOutlet weak var leftGadget1Desc2: UILabel!

    @IBOutlet weak var rightBorderView1: UIView!
    @IBOutlet weak var rightAddButton1: UIButton!
    @IBOutlet weak var rightGadgetView1: UIView!
    @IBOutlet weak var rightGadgetTitle1: UILabel!
    @IBOutlet weak var rightGadgetDesc1: UILabel!
    @IBOutlet weak var rightGadget1Sub1: UILabel!
    @IBOutlet weak var rightGadget1Desc1: UILabel!
    @IBOutlet weak var rightGadget1Sub2: UILabel!
    @IBOutlet weak var rightGadget1Desc2: UILabel!
    
    
    @IBOutlet weak var view2: UIView!
    
    @IBOutlet weak var longGadgetView2: UIView!
    @IBOutlet weak var longBorderView2: UIView!
    @IBOutlet weak var longGadgetTitle2: UILabel!
    @IBOutlet weak var longGadgetDesc2: UILabel!
    
    @IBOutlet weak var longGadget2Sub1: UILabel!
    @IBOutlet weak var longGadget2Desc1: UILabel!
    @IBOutlet weak var longGadget2Sub2: UILabel!
    @IBOutlet weak var longGadget2Desc2: UILabel!
    @IBOutlet weak var longGadget2Sub3: UILabel!
    @IBOutlet weak var longGadget2Desc3: UILabel!
    
    @IBOutlet weak var leftBorderView2: UIView!
    @IBOutlet weak var leftAddButton2: UIButton!
    @IBOutlet weak var leftGadgetView2: UIView!
    @IBOutlet weak var leftGadgetTitle2: UILabel!
    @IBOutlet weak var leftGadgetDesc2: UILabel!
    @IBOutlet weak var leftGadget2Sub1: UILabel!
    @IBOutlet weak var leftGadget2Desc1: UILabel!
    @IBOutlet weak var leftGadget2Sub2: UILabel!
    @IBOutlet weak var leftGadget2Desc2: UILabel!
    
    @IBOutlet weak var rightBorderView2: UIView!
    @IBOutlet weak var rightAddButton2: UIButton!
    @IBOutlet weak var rightGadgetView2: UIView!
    @IBOutlet weak var rightGadgetTitle2: UILabel!
    @IBOutlet weak var rightGadgetDesc2: UILabel!
    @IBOutlet weak var rightGadget2Sub1: UILabel!
    @IBOutlet weak var rightGadget2Desc1: UILabel!
    @IBOutlet weak var rightGadget2Sub2: UILabel!
    @IBOutlet weak var rightGadget2Desc2: UILabel!
    
    
    @IBOutlet weak var view3: UIView!
    
    @IBOutlet weak var longGadgetView3: UIView!
    @IBOutlet weak var longBorderView3: UIView!
    @IBOutlet weak var longGadgetTitle3: UILabel!
    @IBOutlet weak var longGadgetDesc3: UILabel!
    
    @IBOutlet weak var longGadget3Sub1: UILabel!
    @IBOutlet weak var longGadget3Desc1: UILabel!
    @IBOutlet weak var longGadget3Sub2: UILabel!
    @IBOutlet weak var longGadget3Desc2: UILabel!
    @IBOutlet weak var longGadget3Sub3: UILabel!
    @IBOutlet weak var longGadget3Desc3: UILabel!
    
    @IBOutlet weak var leftBorderView3: UIView!
    @IBOutlet weak var leftAddButton3: UIButton!
    @IBOutlet weak var leftGadgetView3: UIView!
    @IBOutlet weak var leftGadgetTitle3: UILabel!
    @IBOutlet weak var leftGadgetDesc3: UILabel!
    @IBOutlet weak var leftGadget3Sub1: UILabel!
    @IBOutlet weak var leftGadget3Desc1: UILabel!
    @IBOutlet weak var leftGadget3Sub2: UILabel!
    @IBOutlet weak var leftGadget3Desc2: UILabel!
    
    @IBOutlet weak var rightBorderView3: UIView!
    @IBOutlet weak var rightAddButton3: UIButton!
    @IBOutlet weak var rightGadgetView3: UIView!
    @IBOutlet weak var rightGadgetTitle3: UILabel!
    @IBOutlet weak var rightGadgetDesc3: UILabel!
    @IBOutlet weak var rightGadget3Sub1: UILabel!
    @IBOutlet weak var rightGadget3Desc1: UILabel!
    @IBOutlet weak var rightGadget3Sub2: UILabel!
    @IBOutlet weak var rightGadget3Desc2: UILabel!
    
    
    @IBOutlet weak var leftAddView1: UIView!
    @IBOutlet weak var leftAddView2: UIView!
    @IBOutlet weak var leftAddView3: UIView!
    
    @IBOutlet weak var rightAddView1: UIView!
    @IBOutlet weak var rightAddView2: UIView!
    @IBOutlet weak var rightAddView3: UIView!
    
    
    @IBOutlet weak var buttonMarcas: UIButton!
    
    var summaryDigitals = [SummaryDigital]()
    var summaryConsumeRanking = [SummaryConsumeRanking]()
    var summaryCampaign = [SummaryCampaign]()
    
    var summaryInversion = [SummaryInversion]()
    var summaryProjected = SummaryProjected(fullYear: 0.0, ytd: 0.0)
    var summaryOrion = SummaryOrion(consumption: 0.0, mediaCredits: 0.0)
    var summaryBilling = SummaryBilling(consumption: 0.0, totalPaid: 0.0)
    
    var reports = [Int]()
    var idCurrency = 2
    var widgetIndex = 0
    
    var isWidgetFull = [true,true,true,true,true,true]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        ResumenManager.shared.resumenVC = self
        
        reports = [0, 0, 1, 2, 3, 3]
        //UserDefaults.standard.setValue(reports, forKey: "resumen")
        if UserDefaults.standard.array(forKey: "resumen") == nil {
            UserDefaults.standard.setValue(reports, forKey: "resumen")
        } else {
            reports = UserDefaults.standard.array(forKey: "resumen") as! [Int]
        }
        
        let userType = UserDefaults.standard.string(forKey: "userType")
        if userType == "HOLDING" {
            buttonMarcas.isHidden = false
        } else {
            buttonMarcas.isHidden = true
        }
        
        leftAddView1.layer.cornerRadius = 10
        leftAddView2.layer.cornerRadius = 10
        leftAddView3.layer.cornerRadius = 10
        rightAddView1.layer.cornerRadius = 10
        rightAddView2.layer.cornerRadius = 10
        rightAddView3.layer.cornerRadius = 10
        
        addShadowCorners(shadowView: longGadgetView1, roundCornerView: longBorderView1)
        addShadowCorners(shadowView: longGadgetView2, roundCornerView: longBorderView2)
        addShadowCorners(shadowView: longGadgetView3, roundCornerView: longBorderView3)
        addShadowCorners(shadowView: leftBorderView1, roundCornerView: leftGadgetView1)
        addShadowCorners(shadowView: leftBorderView2, roundCornerView: leftGadgetView2)
        addShadowCorners(shadowView: leftBorderView3, roundCornerView: leftGadgetView3)
        addShadowCorners(shadowView: rightBorderView1, roundCornerView: rightGadgetView1)
        addShadowCorners(shadowView: rightBorderView2, roundCornerView: rightGadgetView2)
        addShadowCorners(shadowView: rightBorderView3, roundCornerView: rightGadgetView3)
        
        addDashBorders(addView: leftAddButton1)
        addDashBorders(addView: leftAddButton2)
        addDashBorders(addView: leftAddButton3)
        addDashBorders(addView: rightAddButton1)
        addDashBorders(addView: rightAddButton2)
        addDashBorders(addView: rightAddButton3)
        
//        let recognizerAdd1 = UITapGestureRecognizer(target: self, action: #selector(addWidget(_:)))

        let longRec1 = UILongPressGestureRecognizer(target: self, action: #selector(deleteLongWidget1))
        longGadgetView1.addGestureRecognizer(longRec1)
        let longRec2 = UILongPressGestureRecognizer(target: self, action: #selector(deleteLongWidget2))
        longGadgetView2.addGestureRecognizer(longRec2)
        let longRec3 = UILongPressGestureRecognizer(target: self, action: #selector(deleteLongWidget3))
        longGadgetView3.addGestureRecognizer(longRec3)
        
        let leftRec1 = UILongPressGestureRecognizer(target: self, action: #selector(deleteLeftWidget1))
        leftGadgetView1.addGestureRecognizer(leftRec1)
        let leftRec2 = UILongPressGestureRecognizer(target: self, action: #selector(deleteLeftWidget2))
        leftGadgetView2.addGestureRecognizer(leftRec2)
        let leftRec3 = UILongPressGestureRecognizer(target: self, action: #selector(deleteLeftWidget3))
        leftGadgetView3.addGestureRecognizer(leftRec3)
        
        let rightRec1 = UILongPressGestureRecognizer(target: self, action: #selector(deleteRightWidget1))
        rightGadgetView1.addGestureRecognizer(rightRec1)
        let rightRec2 = UILongPressGestureRecognizer(target: self, action: #selector(deleteRightWidget2))
        rightGadgetView2.addGestureRecognizer(rightRec2)
        let rightRec3 = UILongPressGestureRecognizer(target: self, action: #selector(deleteRightWidget3))
        rightGadgetView3.addGestureRecognizer(rightRec3)
        
        getResumen()
    }
    
    func addShadowCorners(shadowView: UIView, roundCornerView: UIView) {
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 3.0
        shadowView.layer.shadowOpacity = 0.5
        shadowView.layer.masksToBounds = false
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 2)
        shadowView.layer.backgroundColor = UIColor.clear.cgColor
        roundCornerView.layer.cornerRadius = 10
        roundCornerView.layer.masksToBounds = true
    }
//    @objc func addWidget(_ gesture: UITapGestureRecognizer) {
//        guard let sender = gesture.view as? UIButton else {
//            print("Sender is not a button")
//            return
//        }
//        print("El tag del button es \(sender.tag)")
//        widgetIndex = sender.tag
//        performSegue(withIdentifier: "goToWidgetsMenu", sender: self)
//    }
    
    @IBAction func addWidget(_ sender: UIButton) {
        widgetIndex = sender.tag
        performSegue(withIdentifier: "goToWidgetsMenu", sender: self)
    }
    
    @objc func deleteLongWidget1() {
        view1.sendSubviewToBack(longGadgetView1)
        longGadgetView1.layer.shadowColor = UIColor.clear.cgColor
        isWidgetFull[0] = false
        isWidgetFull[1] = false
    }
    @objc func deleteLongWidget2() {
        view2.sendSubviewToBack(longGadgetView2)
        longGadgetView2.layer.shadowColor = UIColor.clear.cgColor
        isWidgetFull[2] = false
        isWidgetFull[3] = false
    }
    @objc func deleteLongWidget3() {
        view3.sendSubviewToBack(longGadgetView3)
        longGadgetView3.layer.shadowColor = UIColor.clear.cgColor
        isWidgetFull[4] = false
        isWidgetFull[5] = false
    }
    @objc func deleteLeftWidget1() {
        leftBorderView1.sendSubviewToBack(leftGadgetView1)
        leftBorderView1.layer.shadowColor = UIColor.clear.cgColor
        isWidgetFull[0] = false
    }
    @objc func deleteLeftWidget2() {
        leftBorderView2.sendSubviewToBack(leftGadgetView2)
        leftBorderView2.layer.shadowColor = UIColor.clear.cgColor
        isWidgetFull[2] = false
    }
    @objc func deleteLeftWidget3() {
        leftBorderView3.sendSubviewToBack(leftGadgetView3)
        leftBorderView3.layer.shadowColor = UIColor.clear.cgColor
        isWidgetFull[4] = false
    }
    @objc func deleteRightWidget1() {
        rightBorderView1.sendSubviewToBack(rightGadgetView1)
        rightBorderView1.layer.shadowColor = UIColor.clear.cgColor
        isWidgetFull[1] = false
    }
    @objc func deleteRightWidget2() {
        rightBorderView2.sendSubviewToBack(rightGadgetView2)
        rightBorderView2.layer.shadowColor = UIColor.clear.cgColor
        isWidgetFull[3] = false
    }
    @objc func deleteRightWidget3() {
        rightBorderView3.sendSubviewToBack(rightGadgetView3)
        rightBorderView3.layer.shadowColor = UIColor.clear.cgColor
        isWidgetFull[5] = false
    }
    func sendWidgetToFront(type: Int) {
        switch widgetIndex {
        case 0:
            guard type == 0 else {
                leftBorderView1.bringSubviewToFront(leftGadgetView1)
                leftBorderView1.layer.shadowColor = UIColor.black.cgColor
                isWidgetFull[0] = true
                return
            }
            view1.bringSubviewToFront(longGadgetView1)
            longGadgetView1.layer.shadowColor = UIColor.black.cgColor
            isWidgetFull[0] = true
            isWidgetFull[1] = true
        case 1:
            guard type == 0 else {
                rightBorderView1.bringSubviewToFront(rightGadgetView1)
                rightBorderView1.layer.shadowColor = UIColor.black.cgColor
                isWidgetFull[1] = true
                return
            }
            view1.bringSubviewToFront(longGadgetView1)
            longGadgetView1.layer.shadowColor = UIColor.black.cgColor
            isWidgetFull[0] = true
            isWidgetFull[1] = true
        case 2:
            guard type == 0 else {
                leftBorderView2.bringSubviewToFront(leftGadgetView2)
                leftBorderView2.layer.shadowColor = UIColor.black.cgColor
                isWidgetFull[2] = true
                return
            }
            view2.bringSubviewToFront(longGadgetView2)
            longGadgetView2.layer.shadowColor = UIColor.black.cgColor
            isWidgetFull[2] = true
            isWidgetFull[3] = true
        case 3:
            guard type == 0 else {
                rightBorderView2.bringSubviewToFront(rightGadgetView2)
                rightBorderView2.layer.shadowColor = UIColor.black.cgColor
                isWidgetFull[3] = true
                return
            }
            view2.bringSubviewToFront(longGadgetView2)
            longGadgetView2.layer.shadowColor = UIColor.black.cgColor
            isWidgetFull[2] = true
            isWidgetFull[3] = true
        case 4:
            guard type == 0 else {
                leftBorderView3.bringSubviewToFront(leftGadgetView3)
                leftBorderView3.layer.shadowColor = UIColor.black.cgColor
                isWidgetFull[4] = true
                return
            }
            view3.bringSubviewToFront(longGadgetView3)
            longGadgetView3.layer.shadowColor = UIColor.black.cgColor
            isWidgetFull[4] = true
            isWidgetFull[5] = true
        case 5:
            guard type == 0 else {
                rightBorderView3.bringSubviewToFront(rightGadgetView3)
                rightBorderView3.layer.shadowColor = UIColor.black.cgColor
                isWidgetFull[5] = true
                return
            }
            view3.bringSubviewToFront(longGadgetView3)
            longGadgetView3.layer.shadowColor = UIColor.black.cgColor
            isWidgetFull[4] = true
            isWidgetFull[5] = true
        
        default:
            print("Nothing")
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToWidgetsMenu" {
            let destinationVC = segue.destination as! WidgetMenuVC
            destinationVC.widgetIndex = widgetIndex
            destinationVC.isWidgetFull = isWidgetFull
        }
    }
    func addDashBorders(addView: UIView){
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = UIColor.black.cgColor
        yourViewBorder.lineDashPattern = [2, 2]
        yourViewBorder.fillColor = nil
        
        var addHeight: CGFloat = 0.0
        
        if self.view.frame.height < 700 {
            addHeight = addView.frame.maxY - 35
        } else if self.view.frame.height < 800 {
            addHeight = addView.frame.maxY - 20
        } else {
            addHeight = addView.frame.maxY
        }
        
        if addView.frame.width < self.view.frame.width / 2 {
            yourViewBorder.path = UIBezierPath(rect: CGRect(x: addView.frame.minX + 5, y: addView.frame.minY + 5, width: self.view.frame.width / 2 - 35, height: addHeight)).cgPath
        } else {
            yourViewBorder.path = UIBezierPath(rect: CGRect(x: addView.frame.minX + 5, y: addView.frame.minY + 5, width: self.view.frame.width - 50, height: addHeight)).cgPath
        }
        
        yourViewBorder.cornerRadius = 10.0
        addView.layer.addSublayer(yourViewBorder)
        addView.layer.cornerRadius = 10.0
    }
    
    func getResumen(){
        
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!, "idCurrency": UserDefaults.standard.integer(forKey: "moneda")]
        
        serverManager.serverCallWithHeaders(url: serverManager.resumenURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    let alert = UIAlertController(title: "Error", message: "No hay datos de resumen", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Regresar", style: .default, handler: { (_) in
                        self.tabBarController?.selectedIndex = 1
                    }))
                    self.present(alert, animated: true)
                    return
                }
                for digital in jsonData["summaryDigitals"].arrayValue {
                    let newDigital = SummaryDigital(name: digital["name"].string ?? "", sale: digital["sale"].string ?? "", order: digital["orden"].int ?? 0)
                    self.summaryDigitals.append(newDigital)
                }
                
                for inversion in jsonData["inversions"].arrayValue {
                    let newInversion = SummaryInversion(description: inversion["description"].string ?? "", value: inversion["value"].float ?? 0.0)
                    self.summaryInversion.append(newInversion)
                }
                
                let accountStatus = jsonData["accountStatus"]
                
                self.summaryProjected = SummaryProjected(fullYear: accountStatus["amountFullYear"].float ?? 0.0, ytd: accountStatus["amountYTD"].float ?? 0.0)
                
                self.summaryOrion = SummaryOrion(consumption: accountStatus["annualConsumption"].float ?? 0.0, mediaCredits: accountStatus["mediaCreditsAnual"].float ?? 0.0)
                
                for consumptionRanking in accountStatus["consumptionRanking"].arrayValue {
                    let newConsumption = SummaryConsumeRanking(name: consumptionRanking["crName"].string ?? "", quantity: consumptionRanking["quantity"].float ?? 0.0, order: consumptionRanking["crOrder"].int ?? 0)
                    self.summaryConsumeRanking.append(newConsumption)
                    print(self.summaryConsumeRanking)
                }
                
                for campaign in jsonData["campaignImplementations"].arrayValue {
                    let newCampaign = SummaryCampaign(name: campaign["ciName"].string ?? "", date: campaign["ciDate"].string ?? "")
                    self.summaryCampaign.append(newCampaign)
                    print(self.summaryCampaign)
                }
                
                let billing = jsonData["billing"]
                self.summaryBilling = SummaryBilling(consumption: billing["annualConsumption"].float ?? 0.0, totalPaid: billing["totalPaid"].float ?? 0.0)
                
                self.showResumen(summaryReports: self.reports)
            } else {
                print("Failure")
            }
        })
    }
    
    func getLongReport(order: Int, title: UILabel, description: UILabel, sub1: UILabel, desc1: UILabel, sub2: UILabel, desc2: UILabel, sub3: UILabel, desc3: UILabel) {
        switch order {
        case 0:
            let reports = summaryDigitals
            title.text = "RESUMEN DIGITAL"
            description.text = "Ranking de campaña por alcance"
            if !reports.isEmpty {
                for report in reports {
                    if report.order == 1 {
                        sub1.text = "1. \(report.name)"
                        desc1.text = report.sale
                    } else if report.order == 2 {
                        sub2.text = "2. \(report.name)"
                        desc2.text = report.sale
                    } else {
                        sub3.text = "3. \(report.name)"
                        desc3.text = report.sale
                    }
                }
            }
        case 3:
            let reports = summaryConsumeRanking
            title.text = "ESTADO DE CUENTA"
            description.text = "Ranking de consumos"
            if !reports.isEmpty {
                for report in reports {
                    if report.order == 1 {
                        sub1.text = "1. \(report.name)"
                        desc1.text = "$\(String(format: "%.2f", report.quantity / 1000000))MM"
                    } else if report.order == 2 {
                        sub2.text = "2. \(report.name)"
                        desc2.text = "$\(String(format: "%.2f", report.quantity / 1000000))MM"
                    } else {
                        sub3.text = "3. \(report.name)"
                        desc3.text = "$\(String(format: "%.2f", report.quantity / 1000000))MM"
                    }
                }
            }
        case 6:
            let reports = summaryCampaign
            title.text = "IMPLEMENTACIÓN DE CAMPAÑA"
            description.text = "Últimas implementaciones"
            if !reports.isEmpty {
                sub1.text = "1. \(reports[0].name)"
                desc1.text = reports[0].date

                sub2.text = "2. \(reports[1].name)"
                desc2.text = reports[1].date

                sub3.text = "3. \(reports[2].name)"
                desc3.text = reports[2].date
            }
        default:
            print("Nothing")
        }
    }

    func getShortReport(order: Int, title: UILabel, description: UILabel, sub1: UILabel, desc1: UILabel, sub2: UILabel, desc2: UILabel) {
        switch order {
        case 1:
            let report = summaryInversion
            title.text = "INVERSIÓN"
            description.text = ""
            if !report.isEmpty {
                sub1.text = report[0].description
                desc1.text = "$\(String(format: "%.2f", report[0].value / 1000000))MM"
                sub2.text = report[1].description
                desc2.text = "$\(String(format: "%.2f", report[1].value / 1000000))MM"
            }
        case 2:
            let report = summaryBilling
            title.text = "FACTURACIÓN"
            description.text = ""
            sub1.text = "Consumo anual"
            desc1.text = "$\(String(format: "%.2f", report.consumption / 1000000))MM"
            sub2.text = "Total pagado"
            desc2.text = "$\(String(format: "%.2f", report.totalPaid / 1000000))MM"
        case 4:
            let report = summaryProjected
            title.text = "ESTADO DE CUENTA"
            description.text = "Proyectado"
            sub1.text = "Full year"
            desc1.text = "$\(String(format: "%.2f", report.fullYear / 1000000))MM"
            sub2.text = "YtD"
            desc2.text = "$\(String(format: "%.2f", report.ytd / 1000000))MM"
        case 5:
            let report = summaryOrion
            title.text = "ESTADO DE CUENTA"
            description.text = "Orión"
            sub1.text = "Consumo anual"
            desc1.text = "$\(String(format: "%.2f", report.consumption / 1000000))MM"
            sub2.text = "Media credits anual"
            desc2.text = "$\(String(format: "%.2f", report.mediaCredits / 1000000))MM"
        default:
            print("Nothing")
        }
    }
    

    
    func showResumen(summaryReports: [Int]) {
        if summaryReports[0] == summaryReports[1] {
            view1.bringSubviewToFront(longGadgetView1)
            leftBorderView1.sendSubviewToBack(leftGadgetView1)
            rightBorderView1.sendSubviewToBack(rightGadgetView1)
            leftBorderView1.layer.shadowColor = UIColor.clear.cgColor
            rightBorderView1.layer.shadowColor = UIColor.clear.cgColor
            getLongReport(order: summaryReports[0], title: longGadgetTitle1, description: longGadgetDesc1, sub1: longGadget1Sub1, desc1: longGadget1Desc1, sub2: longGadget1Sub2, desc2: longGadget1Desc2, sub3: longGadget1Sub3, desc3: longGadget1Desc3)
        } else {
            view1.sendSubviewToBack(longGadgetView1)
            leftBorderView1.bringSubviewToFront(leftGadgetView1)
            rightBorderView1.bringSubviewToFront(rightGadgetView1)
            longGadgetView1.layer.shadowColor = UIColor.clear.cgColor
            getShortReport(order: summaryReports[0], title: leftGadgetTitle1, description: leftGadgetDesc1, sub1: leftGadget1Sub1, desc1: leftGadget1Desc1, sub2: leftGadget1Sub2, desc2: leftGadget1Desc2)
            getShortReport(order: summaryReports[1], title: rightGadgetTitle1, description: rightGadgetDesc1, sub1: rightGadget1Sub1, desc1: rightGadget1Desc1, sub2: rightGadget1Sub2, desc2: rightGadget1Desc2)
        }
        
        if summaryReports[2] == summaryReports[3] {
            view2.bringSubviewToFront(longGadgetView2)
            leftBorderView2.sendSubviewToBack(leftGadgetView2)
            rightBorderView2.sendSubviewToBack(rightGadgetView2)
            leftBorderView2.layer.shadowColor = UIColor.clear.cgColor
            rightBorderView2.layer.shadowColor = UIColor.clear.cgColor
            getLongReport(order: summaryReports[2], title: longGadgetTitle2, description: longGadgetDesc2, sub1: longGadget2Sub1, desc1: longGadget2Desc1, sub2: longGadget2Sub2, desc2: longGadget2Desc2, sub3: longGadget2Sub3, desc3: longGadget2Desc3)
        } else {
            view2.sendSubviewToBack(longGadgetView2)
            leftBorderView2.bringSubviewToFront(leftGadgetView2)
            rightBorderView2.bringSubviewToFront(rightGadgetView2)
            longGadgetView2.layer.shadowColor = UIColor.clear.cgColor
            getShortReport(order: summaryReports[2], title: leftGadgetTitle2, description: leftGadgetDesc2, sub1: leftGadget2Sub1, desc1: leftGadget2Desc1, sub2: leftGadget2Sub2, desc2: leftGadget2Desc2)
            getShortReport(order: summaryReports[3], title: rightGadgetTitle2, description: rightGadgetDesc2, sub1: rightGadget2Sub1, desc1: rightGadget2Desc1, sub2: rightGadget2Sub2, desc2: rightGadget2Desc2)
        }
        
        if summaryReports[4] == summaryReports[5] {
            view3.bringSubviewToFront(longGadgetView3)
            leftBorderView3.sendSubviewToBack(leftGadgetView3)
            rightBorderView3.sendSubviewToBack(rightGadgetView3)
            leftBorderView3.layer.shadowColor = UIColor.clear.cgColor
            rightBorderView3.layer.shadowColor = UIColor.clear.cgColor
            getLongReport(order: summaryReports[4], title: longGadgetTitle3, description: longGadgetDesc3, sub1: longGadget3Sub1, desc1: longGadget3Desc1, sub2: longGadget3Sub2, desc2: longGadget3Desc2, sub3: longGadget3Sub3, desc3: longGadget3Desc3)
        } else {
            view3.sendSubviewToBack(longGadgetView3)
            leftBorderView3.bringSubviewToFront(leftGadgetView3)
            rightBorderView3.bringSubviewToFront(rightGadgetView3)
            longGadgetView3.layer.shadowColor = UIColor.clear.cgColor
            getShortReport(order: summaryReports[4], title: leftGadgetTitle3, description: leftGadgetDesc3, sub1: leftGadget3Sub1, desc1: leftGadget3Desc1, sub2: leftGadget3Sub2, desc2: leftGadget3Desc2)
            getShortReport(order: summaryReports[5], title: rightGadgetTitle3, description: rightGadgetDesc3, sub1: rightGadget3Sub1, desc1: rightGadget3Desc1, sub2: rightGadget3Sub2, desc2: rightGadget3Desc2)
        }
    }
    
    func getNewReport(widgetIndex: Int, reportIndex: Int) {
        if reportIndex == 0 || reportIndex == 3 || reportIndex == 6 {
            if widgetIndex < 2 {
                getLongReport(order: reportIndex, title: longGadgetTitle1, description: longGadgetDesc1, sub1: longGadget1Sub1, desc1: longGadget1Desc1, sub2: longGadget1Sub2, desc2: longGadget1Desc2, sub3: longGadget1Sub3, desc3: longGadget1Desc3)
            } else if widgetIndex < 4 {
                getLongReport(order: reportIndex, title: longGadgetTitle2, description: longGadgetDesc2, sub1: longGadget2Sub1, desc1: longGadget2Desc1, sub2: longGadget2Sub2, desc2: longGadget2Desc2, sub3: longGadget2Sub3, desc3: longGadget2Desc3)
            } else {
                getLongReport(order: reportIndex, title: longGadgetTitle3, description: longGadgetDesc3, sub1: longGadget3Sub1, desc1: longGadget3Desc1, sub2: longGadget3Sub2, desc2: longGadget3Desc2, sub3: longGadget3Sub3, desc3: longGadget3Desc3)
            }
        } else {
            switch widgetIndex {
                case 0:
                    getShortReport(order: reportIndex, title: leftGadgetTitle1, description: leftGadgetDesc1, sub1: leftGadget1Sub1, desc1: leftGadget1Desc1, sub2: leftGadget1Sub2, desc2: leftGadget1Desc2)
                case 1:
                    getShortReport(order: reportIndex, title: rightGadgetTitle1, description: rightGadgetDesc1, sub1: rightGadget1Sub1, desc1: rightGadget1Desc1, sub2: rightGadget1Sub2, desc2: rightGadget1Desc2)
                case 2:
                    getShortReport(order: reportIndex, title: leftGadgetTitle2, description: leftGadgetDesc2, sub1: leftGadget2Sub1, desc1: leftGadget2Desc1, sub2: leftGadget2Sub2, desc2: leftGadget2Desc2)
                    
                case 3:
                    getShortReport(order: reportIndex, title: rightGadgetTitle2, description: rightGadgetDesc2, sub1: rightGadget2Sub1, desc1: rightGadget2Desc1, sub2: rightGadget2Sub2, desc2: rightGadget2Desc2)
                case 4:
                    getShortReport(order: reportIndex, title: leftGadgetTitle3, description: leftGadgetDesc3, sub1: leftGadget3Sub1, desc1: leftGadget3Desc1, sub2: leftGadget3Sub2, desc2: leftGadget3Desc2)
                    
                case 5:
                    getShortReport(order: reportIndex, title: rightGadgetTitle3, description: rightGadgetDesc3, sub1: rightGadget3Sub1, desc1: rightGadget3Desc1, sub2: rightGadget3Sub2, desc2: rightGadget3Desc2)
                default:
                    print("Nothing")
            }
        }
    }
    @IBAction func showMenu(_ sender: UIButton) {
        let menu = storyboard!.instantiateViewController(withIdentifier: "LeftMenu") as! SideMenuNavigationController
        menu.presentationStyle = .menuSlideIn
        menu.presentationStyle.presentingEndAlpha = 0.5
        menu.presentationStyle.onTopShadowOpacity = 1
        present(menu, animated: true, completion: nil)
    }
    @IBAction func returnToMarcas(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}


