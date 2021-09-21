//
//  FacturacionBalanceVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/30/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class FacturacionBalanceVC: UIViewController {

    @IBOutlet weak var tabBalance: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabBalance.frame.size.height - 2, width: tabBalance.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tabBalance.layer.addSublayer(bottomBorder)
        }
    }
    @IBOutlet weak var tabDetalle: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabDetalle.frame.size.height - 2, width: tabDetalle.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            tabDetalle.layer.addSublayer(bottomBorder)
        }
    }
    @IBOutlet weak var totalConsumido: UILabel!
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var totalFacturado: UILabel!
    @IBOutlet weak var totalPorFacturar: UILabel!
    @IBOutlet weak var totalPagado: UILabel!
    @IBOutlet weak var totalPorPagar: UILabel!
    
    @IBOutlet weak var totalFacturadoView: UIView!
    @IBOutlet weak var totalPorFacturarView: UIView!
    @IBOutlet weak var totalPagadoView: UIView!
    @IBOutlet weak var totalPorPagarView: UIView!
    
    @IBOutlet weak var totalConsumedView: UIView!
//    {
//        didSet {
//            let topLayer = CALayer()
//            topLayer.frame = CGRect(x: 0.0, y: totalConsumedView.frame.height , width: totalConsumedView.frame.width, height: 1.0)
//
//            let topBorder = CAShapeLayer()
//            topBorder.strokeColor = UIColor.black.cgColor
//            topBorder.lineWidth = 1
//            topBorder.lineDashPattern = [2, 2]
//            topBorder.frame = topLayer.bounds
//            topBorder.fillColor = nil
//            topBorder.path = UIBezierPath(rect: topLayer.bounds).cgPath
//            
//            topLayer.addSublayer(topBorder)
//            totalConsumedView.layer.addSublayer(topLayer)
//        }
//    }
    var lineChart = LineChartView()
    var idCurrency = 2
    var graphData = [GraphElement]()
    var graphicColors: [UIColor] = [UIColor(rgb: 0x7F2246), UIColor(rgb: 0xD93251), UIColor(rgb: 0x3F7F91), UIColor(rgb: 0x2C274C), UIColor(rgb: 0x3F7791), UIColor(rgb: 0x42173E), UIColor(rgb: 0xA3294A), UIColor(rgb: 0x37547F)]
    let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    
    let monthsInitials = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Dic"]
    
    let date = Date()
    let calendar = Calendar.current
    var year = 2020
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        year = calendar.component(.year, from: date)
        
        totalFacturadoView.layer.cornerRadius = 10
        totalPorFacturarView.layer.cornerRadius = 10
        totalPagadoView.layer.cornerRadius = 10
        totalPorPagarView.layer.cornerRadius = 10
     
        getLineChart()
    }
    
    func getLineChart() {
        self.graphData.removeAll()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["year": year, "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        
        serverManager.serverCallWithHeaders(url: serverManager.facturacionURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                var totalFacturadoQ: Float = 0.0
                var totalPorFacturarQ: Float = 0.0
                var totalPagadoQ: Float = 0.0
                var totalPorPagarQ: Float = 0.0
                
                for i in 0..<12 {
                    let element = GraphElement(name: self.months[i], amount: 0.0)
                    self.graphData.append(element)
                }
                
                for month in jsonData["billings"].arrayValue {
            
                    let index = self.graphData.firstIndex(where: { $0.name.caseInsensitiveCompare(month["month"].string!) == .orderedSame })
                    self.graphData[Int(index!)].amount += month["amountConsumed"].float ?? 0
                    totalFacturadoQ += month["amountInvoice"].float ?? 0
                    totalPorFacturarQ += month["amountToBilled"].float ?? 0
                    totalPagadoQ += month["amountPaid"].float ?? 0
                    totalPorPagarQ += month["amountToPay"].float ?? 0
                }
                
                self.totalFacturado.text = "$ \(Double(totalFacturadoQ / 1000000).round(to: 2))MM"
                self.totalPorFacturar.text = "$ \(Double(totalPorFacturarQ / 1000000).round(to: 2))MM"
                self.totalPagado.text = "$ \(Double(totalPagadoQ / 1000000).round(to: 2))MM"
                self.totalPorPagar.text = "$ \(Double(totalPorPagarQ / 1000000).round(to: 2))MM"
                
                self.graphData = self.graphData.filter{ $0.amount > 0}
                print(self.graphData)
                print(self.graphData.count)
                self.showLineChart(dataPoints: self.monthsInitials)
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func showLineChart(dataPoints: [String]) {
        if self.graphData.count > 0 {
            clearGraphView()

            self.lineChart.frame = CGRect(x: 0, y: 0, width: self.graphView.frame.size.width, height: self.graphView.frame.height - 20)

            // Y - Axis Setup
            let yaxis = self.lineChart.leftAxis
            yaxis.drawGridLinesEnabled = false
            yaxis.labelTextColor = UIColor.white
            yaxis.axisLineColor = UIColor.white
            yaxis.labelPosition = .insideChart
            yaxis.enabled = false
            self.lineChart.rightAxis.enabled = false

            // X - Axis Setup
            let xaxis = self.lineChart.xAxis
            xaxis.drawGridLinesEnabled = false
            xaxis.labelTextColor = UIColor.black
            xaxis.axisLineColor = UIColor.white
            xaxis.granularityEnabled = true
            xaxis.enabled = true
            xaxis.labelPosition = .bottom
            xaxis.labelFont = UIFont(name: "Aldine721BT-Roman",
                                     size: 14.0)!
            xaxis.drawGridLinesEnabled = false
            xaxis.valueFormatter = IndexAxisValueFormatter(values: self.monthsInitials)
            
            self.graphView.addSubview(self.lineChart)

            var entries = [ChartDataEntry]()
            
            var totalConsumed = 0.0
            for x in 0..<graphData.count {
                entries.append(ChartDataEntry(x: Double(x), y: Double(graphData[x].amount / 1000000).round(to: 2)))
                totalConsumed += Double(graphData[x].amount / 1000000).round(to: 2)
            }
            
            self.totalConsumido.text = "$ \(String(format: "%.2f", totalConsumed))MM"
            
            let set = LineChartDataSet(values: entries, label: "1")
            set.mode = .linear
            set.setCircleColor(UIColor(rgb: 0x59C7ED))
            set.circleHoleColor = UIColor(rgb: 0x59C7ED)
            set.setColor(UIColor(rgb: 0x59C7ED))
            set.circleRadius = 0
            set.lineWidth = 2
            set.drawValuesEnabled = false
            let data = LineChartData(dataSet: set)
            self.lineChart.data = data
        
            self.lineChart.chartDescription.enabled = false
            self.lineChart.legend.enabled = false
            self.lineChart.rightAxis.enabled = false
            self.lineChart.keepPositionOnRotation = true
            self.lineChart.clipValuesToContentEnabled = true

            self.lineChart.setVisibleXRangeMaximum(8)
            self.lineChart.animate(yAxisDuration: 1.0, easingOption: .linear)
            self.lineChart.doubleTapToZoomEnabled = false
            
        } else {
            self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
        }
    }
    
    func clearGraphView() {
        self.lineChart.removeFromSuperview()
    }
    
    @IBAction func goToDetalle(_ sender: UIButton) {
        performSegue(withIdentifier: "goToDetalle", sender: self)
    }
    @IBAction func returnToListado(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}
