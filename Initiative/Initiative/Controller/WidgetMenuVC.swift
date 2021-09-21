//
//  WidgetMenuVC.swift
//  Initiative
//
//  Created by Andres Liu on 12/22/20.
//

import UIKit
import Alamofire
import SwiftyJSON

class WidgetMenuVC: UIViewController {

    @IBOutlet weak var firstWidgetTitle1: UILabel!
    @IBOutlet weak var firstWidgetTitle2: UILabel!
    @IBOutlet weak var firstWidgetTitle3: UILabel!
    
    @IBOutlet weak var firstWidgetDesc1: UILabel!
    @IBOutlet weak var firstWidgetDesc2: UILabel!
    @IBOutlet weak var firstWidgetDesc3: UILabel!
    
    @IBOutlet weak var secondWidgetTitle1: UILabel!
    @IBOutlet weak var secondWidgetTitle2: UILabel!
    
    @IBOutlet weak var secondWidgetDesc1: UILabel!
    @IBOutlet weak var secondWidgetDesc2: UILabel!
    
    @IBOutlet weak var thirdWidgetTitle1: UILabel!
    @IBOutlet weak var thirdWidgetTitle2: UILabel!
    
    @IBOutlet weak var thirdWidgetDesc1: UILabel!
    @IBOutlet weak var thirdWidgetDesc2: UILabel!
    
    @IBOutlet weak var fourthWidgetTitle1: UILabel!
    @IBOutlet weak var fourthWidgetTitle2: UILabel!
    @IBOutlet weak var fourthWidgetTitle3: UILabel!
    
    @IBOutlet weak var fourthWidgetDesc1: UILabel!
    @IBOutlet weak var fourthWidgetDesc2: UILabel!
    @IBOutlet weak var fourthWidgetDesc3: UILabel!
    
    @IBOutlet weak var fifthWidgetTitle1: UILabel!
    @IBOutlet weak var fifthWidgetTitle2: UILabel!
    
    @IBOutlet weak var fifthWidgetDesc1: UILabel!
    @IBOutlet weak var fifthWidgetDesc2: UILabel!
    
    @IBOutlet weak var sixthWidgetTitle1: UILabel!
    @IBOutlet weak var sixthWidgetTitle2: UILabel!
    
    @IBOutlet weak var sixthWidgetDesc1: UILabel!
    @IBOutlet weak var sixthWidgetDesc2: UILabel!
    
    @IBOutlet weak var seventhWidgetTitle1: UILabel!
    @IBOutlet weak var seventhWidgetTitle2: UILabel!
    @IBOutlet weak var seventhWidgetTitle3: UILabel!
    
    @IBOutlet weak var seventhWidgetDesc1: UILabel!
    @IBOutlet weak var seventhWidgetDesc2: UILabel!
    @IBOutlet weak var seventhWidgetDesc3: UILabel!
    
    
    @IBOutlet weak var firstWidgetView: UIView!
    
    @IBOutlet weak var secondWidgetView: UIView!
    
    @IBOutlet weak var thirdWidgetView: UIView!
    
    @IBOutlet weak var fourthWidgetView: UIView!
    
    @IBOutlet weak var fifthWidgetView: UIView!
    
    @IBOutlet weak var sixthWidgetView: UIView!
    
    @IBOutlet weak var seventhWidgetView: UIView!
    
    var summaryDigitals = [SummaryDigital]()
    var summaryConsumeRanking = [SummaryConsumeRanking]()
    var summaryCampaign = [SummaryCampaign]()
    
    var summaryInversion = [SummaryInversion]()
    var summaryProjected = SummaryProjected(fullYear: 0.0, ytd: 0.0)
    var summaryOrion = SummaryOrion(consumption: 0.0, mediaCredits: 0.0)
    var summaryBilling = SummaryBilling(consumption: 0.0, totalPaid: 0.0)
    
    var widgetIndex = 0
    var isWidgetFull = [Bool]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        firstWidgetView.layer.cornerRadius = 10.0
        firstWidgetView.layer.masksToBounds = true
        secondWidgetView.layer.cornerRadius = 10.0
        secondWidgetView.layer.masksToBounds = true
        thirdWidgetView.layer.cornerRadius = 10.0
        thirdWidgetView.layer.masksToBounds = true
        fourthWidgetView.layer.cornerRadius = 10.0
        fourthWidgetView.layer.masksToBounds = true
        fifthWidgetView.layer.cornerRadius = 10.0
        fifthWidgetView.layer.masksToBounds = true
        sixthWidgetView.layer.cornerRadius = 10.0
        sixthWidgetView.layer.masksToBounds = true
        seventhWidgetView.layer.cornerRadius = 10.0
        seventhWidgetView.layer.masksToBounds = true
        
        thirdWidgetTitle1.adjustsFontSizeToFitWidth = true
        thirdWidgetTitle2.adjustsFontSizeToFitWidth = true
        getResumen()
    }
    
    func getResumen(){
        
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!, "idCurrency": UserDefaults.standard.integer(forKey: "moneda")]
        
        serverManager.serverCallWithHeaders(url: serverManager.resumenURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    let alert = UIAlertController(title: "Error", message: "No hay datos de resumen", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Regresar", style: .default, handler: { (_) in
                        self.dismiss(animated: true, completion: nil)
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
                    
                }
                
                for campaign in jsonData["campaignImplementations"].arrayValue {
                    let newCampaign = SummaryCampaign(name: campaign["ciName"].string ?? "", date: campaign["ciDate"].string ?? "")
                    self.summaryCampaign.append(newCampaign)
                    
                }
                
                let billing = jsonData["billing"]
                self.summaryBilling = SummaryBilling(consumption: billing["annualConsumption"].float ?? 0.0, totalPaid: billing["totalPaid"].float ?? 0.0)
                
                self.showWidget()
            } else {
                print("Failure")
            }
        })
    }
    
    func showWidget() {
        
        // 1st Widget - Resumen digital
        if !summaryDigitals.isEmpty {
            for report in summaryDigitals {
                if report.order == 1 {
                    firstWidgetTitle1.text = "1. \(report.name)"
                    firstWidgetDesc1.text = report.sale
                } else if report.order == 2 {
                    firstWidgetTitle2.text = "2. \(report.name)"
                    firstWidgetDesc2.text = report.sale
                } else {
                    firstWidgetTitle3.text = "3. \(report.name)"
                    firstWidgetDesc3.text = report.sale
                }
            }
        }
        
        // 2nd Widget - Inversion
        if !summaryInversion.isEmpty {
            secondWidgetTitle1.text = summaryInversion[0].description
            secondWidgetDesc1.text = "$\(String(format: "%.2f", summaryInversion[0].value / 1000000))MM"
            secondWidgetTitle2.text = summaryInversion[1].description
            secondWidgetDesc2.text = "$\(String(format: "%.2f", summaryInversion[1].value / 1000000))MM"
        }
        
        // 3er Widget - Facturacion
        thirdWidgetTitle1.text = "Consumo anual"
        thirdWidgetDesc1.text = "$\(String(format: "%.2f", summaryBilling.consumption / 1000000))MM"
        thirdWidgetTitle2.text = "Total pagado"
        thirdWidgetDesc2.text = "$\(String(format: "%.2f", summaryBilling.totalPaid / 1000000))MM"
        
        // 4th Widget - Estado de cuenta - Ranking de consumos
        if !summaryConsumeRanking.isEmpty {
            for report in summaryConsumeRanking {
                if report.order == 1 {
                    fourthWidgetTitle1.text = "1. \(report.name)"
                    fourthWidgetDesc1.text = "$\(String(format: "%.2f", report.quantity / 1000000))MM"
                } else if report.order == 2 {
                    fourthWidgetTitle2.text = "2. \(report.name)"
                    fourthWidgetDesc2.text = "$\(String(format: "%.2f", report.quantity / 1000000))MM"
                } else {
                    fourthWidgetTitle3.text = "3. \(report.name)"
                    fourthWidgetDesc3.text = "$\(String(format: "%.2f", report.quantity / 1000000))MM"
                }
            }
        }
        
        // 5th Widget - Estado de cuenta - Proyectado
        fifthWidgetTitle1.text = "Full year"
        fifthWidgetDesc1.text = "$\(String(format: "%.2f", summaryProjected.fullYear / 1000000))MM"
        fifthWidgetTitle2.text = "YtD"
        fifthWidgetDesc2.text = "$\(String(format: "%.2f", summaryProjected.ytd / 1000000))MM"
        
        // 6th Widget - Estado de cuenta - Orion
        sixthWidgetTitle1.text = "Consumo anual"
        sixthWidgetDesc1.text = "$\(String(format: "%.2f", summaryOrion.consumption / 1000000))MM"
        sixthWidgetTitle2.text = "Media credits anual"
        sixthWidgetDesc2.text = "$\(String(format: "%.2f", summaryOrion.mediaCredits / 1000000))MM"
        
        // 7th Widget - Implementacion de campaña
        if !summaryCampaign.isEmpty {
            seventhWidgetTitle1.text = "1. \(summaryCampaign[0].name)"
            seventhWidgetDesc1.text = summaryCampaign[0].date

            seventhWidgetTitle2.text = "2. \(summaryCampaign[1].name)"
            seventhWidgetDesc2.text = summaryCampaign[1].date

            seventhWidgetTitle3.text = "3. \(summaryCampaign[2].name)"
            seventhWidgetDesc3.text = summaryCampaign[2].date
        }
    }
    
    @IBAction func pressWidget(_ sender: UIButton) {
        
        var reports = UserDefaults.standard.array(forKey: "resumen") as! [Int]
        var reportType = 0
        if sender.tag == 0 || sender.tag == 3 || sender.tag == 6 {
            
            if widgetIndex < 2 {
                guard !isWidgetFull[0] && !isWidgetFull[1] else {
                    showAlert(title: "Error", message: "No hay suficiente espacio")
                    return
                }
            } else if widgetIndex < 4 {
                guard !isWidgetFull[2] && !isWidgetFull[3] else {
                    showAlert(title: "Error", message: "No hay suficiente espacio")
                    return
                }
            } else {
                guard !isWidgetFull[4] && !isWidgetFull[5] else {
                    showAlert(title: "Error", message: "No hay suficiente espacio")
                    return
                }
            }
    
            if widgetIndex % 2 == 0 {
                reports[widgetIndex + 1] = sender.tag
            } else {
                reports[widgetIndex - 1] = sender.tag
            }
            reportType = 0
            reports[widgetIndex] = sender.tag
            UserDefaults.standard.setValue(reports, forKey: "resumen")
            
        } else {
            reportType = 1
            reports[widgetIndex] = sender.tag
            UserDefaults.standard.setValue(reports, forKey: "resumen")
        }
        
        ResumenManager.shared.resumenVC.getNewReport(widgetIndex: widgetIndex, reportIndex: sender.tag)
        ResumenManager.shared.resumenVC.sendWidgetToFront(type: reportType)
        dismiss(animated: true, completion: nil)
    }
}
