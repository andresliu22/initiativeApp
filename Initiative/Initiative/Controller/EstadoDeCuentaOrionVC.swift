//
//  EstadoDeCuentaOrionVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/30/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class EstadoDeCuentaOrionVC: UIViewController {

    @IBOutlet weak var tabProyectado: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabProyectado.frame.size.height - 2, width: tabProyectado.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            tabProyectado.layer.addSublayer(bottomBorder)
        }
    }
    @IBOutlet weak var tabContratos: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabContratos.frame.size.height - 2, width: tabContratos.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            tabContratos.layer.addSublayer(bottomBorder)
        }
    }
    @IBOutlet weak var tabOrion: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabOrion.frame.size.height - 2, width: tabOrion.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tabOrion.layer.addSublayer(bottomBorder)
        }
    }
    
    @IBOutlet weak var consumoAnualOrion: UILabel!
    @IBOutlet weak var mediaCreditsAnualOrion: UILabel!
    @IBOutlet weak var consumoOrionView: UIStackView!
    @IBOutlet weak var buttonYear: UIButton!
    @IBOutlet weak var graphView: UIView!
    
    @IBOutlet weak var legendCV: UICollectionView!
    
    @IBOutlet weak var consumoGaugeView: UIView!
    @IBOutlet weak var mediaGaugeView: UIView!
    
    var consumoGaugeGraph = GaugeView(frame: CGRect(x: 0, y: 0, width: 150, height: 75))
    var mediaGaugeGraph = GaugeView(frame: CGRect(x: 0, y: 0, width: 150, height: 75))
    
    var arrayYear = [Int]()

    var yearList = [FilterBody]()
    
    var arrayBeforeFilter = [Int]()
    
    let transparentView = UIView()
    let borderView = UIView()
    let inBetweenView = UIView()
    let searchBar = UISearchBar()
    let tableView = UITableView()
    var selectedButton = UIButton()
    var barChart = BarChartView()
    
    var dataSource = [FilterBody]()
    var dataSearch = [FilterBody]()
    var searching = false
    var didSelect = false
    var idCurrency = 2
    
    var graphData = [EstadoCuentaOrionStruct]()
    
    var graphicColors: [UIColor] = [UIColor(rgb: 0x365381), UIColor(rgb: 0xD0173D)]
    let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    
    let monthsInitials = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Dic"]
    let legendValues = ["Consumo mensual orion", "Media credits orion"]
    override func viewDidLoad() {
        super.viewDidLoad()

        consumoOrionView.layer.cornerRadius = 10
        
        buttonYear.addBorders(width: 1)
        buttonYear.titleEdgeInsets.left = 10
        buttonYear.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
    
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(CellClass.self, forCellReuseIdentifier: "ImplementacionCell")

        self.searchBar.delegate = self
        self.legendCV.dataSource = self
        self.legendCV.delegate = self
        self.tableView.reloadData()
        
        consumoGaugeGraph.value = 0
        consumoGaugeGraph.backgroundColor = .clear
        consumoGaugeView.addSubview(consumoGaugeGraph)
        
        mediaGaugeGraph.value = 0
        mediaGaugeGraph.backgroundColor = .clear
        mediaGaugeView.addSubview(mediaGaugeGraph)
        
        addLineBorder()
        getFilters()
    }
    
    func addLineBorder() {
        let topLayer = CALayer()
        topLayer.frame = CGRect(x: 30.0, y: 0, width: self.view.frame.width - 60 , height: 1.0)

        let topBorder = CAShapeLayer()
        topBorder.strokeColor = UIColor.black.cgColor
        topBorder.lineWidth = 1
        topBorder.lineDashPattern = [2, 2]
        topBorder.frame = topLayer.bounds
        topBorder.fillColor = nil
        topBorder.path = UIBezierPath(rect: topLayer.bounds).cgPath
        
        topLayer.addSublayer(topBorder)
        legendCV.layer.addSublayer(topLayer)
    }
    func getFilters() {
        yearList = NetworkManager.shared.getYears()
        
//        for i in 0..<yearList.count {
//            arrayYear.append(yearList[i].id)
//        }
        arrayYear.append(yearList[yearList.count - 1].id)
        buttonYear.setTitle(yearList[yearList.count - 1].name, for: .normal)
        getBarChart()
    }
    
    func getBarChart() {
        self.graphData.removeAll()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["year": arrayYear[0], "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": "C1"]
        
        serverManager.serverCallWithHeaders(url: serverManager.estadoCuentaOrionURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                let data = jsonData["orion"]
                for i in 0..<12 {
                    let element = EstadoCuentaOrionStruct(name: self.months[i], annualConsumption: 0.0, mediaCredits: 0.0)
                    self.graphData.append(element)
                }
                
                var annualConsumptionCurrent = ""
                if data["annualConsumptionCurrent"].float! < 1000 {
                    annualConsumptionCurrent = "$ \(String(format: "%.2f", data["annualConsumptionCurrent"].float!))"
                } else if data["annualConsumptionCurrent"].float! < 1000000 {
                    annualConsumptionCurrent = "$ \(String(format: "%.2f", data["annualConsumptionCurrent"].float!/1000))K"
                } else {
                    annualConsumptionCurrent = "$ \(String(format: "%.2f", data["annualConsumptionCurrent"].float!/1000000))MM"
                }
                
                self.consumoAnualOrion.text = annualConsumptionCurrent
                //anualConsumptionExpected
                
                var mediaCreditsCurrent = ""
                if data["mediaCreditsCurrent"].float! < 1000 {
                    mediaCreditsCurrent = "$ \(String(format: "%.2f", data["mediaCreditsCurrent"].float!))"
                } else if data["mediaCreditsCurrent"].float! < 1000000 {
                    mediaCreditsCurrent = "$ \(String(format: "%.2f", data["mediaCreditsCurrent"].float!/1000))K"
                } else {
                    mediaCreditsCurrent = "$ \(String(format: "%.2f", data["mediaCreditsCurrent"].float!/1000000))MM"
                }
                
                self.mediaCreditsAnualOrion.text = mediaCreditsCurrent
                //mediaCreditsExpected
                
                for mes in data["months"].arrayValue {
                    let index = self.graphData.firstIndex(where: { $0.name.caseInsensitiveCompare(mes["name"].string!) == .orderedSame })
                    self.graphData[Int(index!)].annualConsumption += mes["amountAnnualConsumption"].float!
                    self.graphData[Int(index!)].mediaCredits += mes["amountMediCredits"].float!

                }
                    
                //self.graphData = self.graphData.filter{ $0.annualConsumption > 0}
                print(self.graphData)
                print(self.graphData.count)
                
                self.consumoGaugeGraph.value = Int(data["annualConsumptionCurrent"].float! / data["annualConsumptionExpected"].float! * 100)
                self.mediaGaugeGraph.value = Int(data["mediaCreditsCurrent"].float! / data["mediaCreditsExpected"].float! * 100)
                
                if self.consumoGaugeGraph.value > 100 {
                    self.consumoGaugeGraph.value = 100
                }
                if self.mediaGaugeGraph.value > 100 {
                    self.mediaGaugeGraph.value = 100
                }
                
                self.consumoGaugeGraph.valueArea = self.consumoGaugeGraph.value
                self.mediaGaugeGraph.valueArea = self.mediaGaugeGraph.value
                self.consumoGaugeGraph.setNeedsDisplay()
                self.mediaGaugeGraph.setNeedsDisplay()
                
                self.showBarChart(dataPoints: self.monthsInitials)
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func showBarChart(dataPoints: [String]) {
        if self.graphData.count > 0 {
            clearGraphView()
            
//            let formatter = BarChartFormatter()
//            formatter.setValues(values: dataPoints)
//            let bottomLabelsAxis: XAxis = XAxis()
//            bottomLabelsAxis.valueFormatter = formatter

            self.barChart.frame = CGRect(x: 10, y: 10, width: self.graphView.frame.size.width, height: self.graphView.frame.height - 20)

            // Y - Axis Setup
            let yaxis = self.barChart.leftAxis
            yaxis.drawGridLinesEnabled = false
            yaxis.labelTextColor = UIColor.clear
            yaxis.axisLineColor = UIColor.clear
            yaxis.labelPosition = .insideChart
            yaxis.enabled = true
            yaxis.spaceTop = 0.35
            yaxis.axisMinimum = 0
            
            // X - Axis Setup
            let xaxis = self.barChart.xAxis
            xaxis.drawGridLinesEnabled = false
            xaxis.labelTextColor = UIColor.black
            xaxis.axisLineColor = UIColor.white
            xaxis.granularityEnabled = true
            xaxis.enabled = true
            xaxis.labelPosition = .bottom
            xaxis.labelFont = UIFont(name: "LeagueGothic-Regular",
                                    size: 20.0)!
            //xaxis.valueFormatter = bottomLabelsAxis.valueFormatter
            xaxis.centerAxisLabelsEnabled = true
            xaxis.valueFormatter = IndexAxisValueFormatter(values: self.monthsInitials)
            xaxis.granularity = 1
            
            graphView.addSubview(barChart)

            var entries = [BarChartDataEntry]()
            var entries2 = [BarChartDataEntry]()
            
            for x in 0..<graphData.count {
                entries.append(BarChartDataEntry(x: Double(x), y: Double(graphData[x].annualConsumption / 1000).round(to: 2)))
                
                entries2.append(BarChartDataEntry(x: Double(x), y: Double(graphData[x].mediaCredits / 1000).round(to: 2)))
            }
            
            let set = BarChartDataSet(values: entries, label: "Consumed")
            let set2 = BarChartDataSet(values: entries2, label: "Media credits")
            
            set.drawValuesEnabled = false
            set.colors =  [UIColor(rgb: 0x365381)]
            set.valueColors = [.black]
            set.valueLabelAngle = -90
            
            set2.drawValuesEnabled = false
            set2.colors =  [UIColor(rgb: 0xD0173D)]
            set2.valueColors = [.black]
            set2.valueLabelAngle = -90
            
            let barChartRenderer = BarChartEstadoDeCuentaContratosRenderer(dataProvider: barChart, animator: barChart.chartAnimator, viewPortHandler: barChart.viewPortHandler)
            barChart.renderer = barChartRenderer
            
            var datasets = [BarChartDataSet]()
            datasets.append(set)
            datasets.append(set2)
            
            let chartData = BarChartData(dataSets: datasets)
            
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .currency
            pFormatter.maximumFractionDigits = 0
            pFormatter.multiplier = 1.0
            //pFormatter.zeroSymbol = ""
            pFormatter.currencySymbol = "$"
            pFormatter.positiveSuffix = "K"
            chartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
            chartData.setDrawValues(true)
            chartData.setValueTextColor(UIColor.black)
            
            let groupSpace = 0.3
            let barSpace = 0.05
            let barWidth = 0.3
            // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"

            let groupCount = self.months.count
            let startYear = 0

            chartData.barWidth = barWidth
            barChart.xAxis.axisMinimum = Double(startYear)
            let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            barChart.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)
            chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
            barChart.notifyDataSetChanged()
            barChart.data = chartData
            barChart.data?.setValueFont(UIFont(name: "Aldine721BT-Roman",
                                                    size: 12.0)!)
            
            barChart.chartDescription.enabled = false
            barChart.legend.enabled = false
            barChart.rightAxis.enabled = false
            barChart.drawValueAboveBarEnabled = true
            barChart.setVisibleXRangeMaximum(6)
            barChart.animate(yAxisDuration: 1.0, easingOption: .linear)
            barChart.doubleTapToZoomEnabled = false
            self.barChart.highlightPerTapEnabled = false
            
        } else {
            self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
        }
    }
    
    func clearGraphView() {
        self.barChart.removeFromSuperview()
    }
    
    func addTransparentView(searchPlaceholder: String) {
        let frames = self.view.frame
        transparentView.frame = self.view.frame
        
        self.borderView.frame = CGRect(x: frames.minX, y: frames.maxY, width: frames.width, height: 0)
        self.searchBar.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
        self.inBetweenView.frame = CGRect(x: frames.minX, y: frames.maxY, width: frames.width - 60, height: 0)
        self.tableView.frame = CGRect(x: frames.minX + 30, y: frames.maxY, width: frames.width - 60, height: 0)
        
        self.view.addSubview(transparentView)
        self.view.addSubview(borderView)
        self.view.addSubview(searchBar)
        self.view.addSubview(inBetweenView)
        self.view.addSubview(tableView)
        
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
            getBarChart()
            didSelect = false
        } else {
            if arrayYear.isEmpty {
                arrayYear = arrayBeforeFilter
            }
            print("No hubo cambio en filtro")
        }
    }
    
    @IBAction func onClickBtnYear(_ sender: UIButton) {
        dataSource = yearList
        selectedButton = buttonYear
        arrayBeforeFilter = arrayYear
        arrayYear.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "año...")
    }
    @IBAction func goToProyectado(_ sender: UIButton) {
        let  vc =  self.navigationController?.viewControllers.filter({$0 is EstadoDeCuentaProyectadoVC}).first
        self.navigationController?.popToViewController(vc!, animated: false)
    }
    
    @IBAction func goToContratos(_ sender: UIButton) {
        if let vc =  self.navigationController?.viewControllers.filter({$0 is EstadoDeCuentaContratosVC}).first {
            self.navigationController?.popToViewController(vc, animated: false)
        } else {
            performSegue(withIdentifier: "fromOrionToContratos", sender: self)
        }
        
    }
    
    @IBAction func returnToListado(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension EstadoDeCuentaOrionVC: UITableViewDataSource {
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
        
        var arrayValues = [Int]()
        
        switch (selectedButton) {
            case buttonYear:
                arrayValues = arrayYear
            default:
                arrayValues = arrayYear
        }
        
        
        var valueSelected: FilterBody
        if searching {
            valueSelected = FilterBody(id: dataSearch[indexPath.row].id, name: dataSearch[indexPath.row].name)
        } else {
            valueSelected = FilterBody(id: dataSource[indexPath.row].id, name: dataSource[indexPath.row].name)
        }
        
        arrayValues.append(valueSelected.id)
        
        if arrayValues.count == 1 {
            selectedButton.setTitle(valueSelected.name, for: .normal)
        } else if arrayValues.count > 1 && arrayValues.count < dataSource.count {
            selectedButton.setTitle("Varios", for: .normal)
        } else if arrayValues.count >= dataSource.count {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            selectedButton.setTitle("Todos", for: .normal)
        }
        
        switch (selectedButton) {
            case buttonYear:
                arrayYear = arrayValues
            default:
                arrayYear = arrayValues
        }
        
        didSelect = true
        print(arrayValues)
        removeTransparentView()
        
    }
    
}

extension EstadoDeCuentaOrionVC: UITableViewDelegate {
    
}

extension EstadoDeCuentaOrionVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSearch = dataSource.filter({$0.name.uppercased().contains(searchText.uppercased())})
        if searchText != "" {
            searching = true
        } else {
            searching = false
        }
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        switch (selectedButton) {
            case buttonYear:
                arrayYear.removeAll()
            default:
                arrayYear.removeAll()
        }
    }
}

extension EstadoDeCuentaOrionVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondLegend", for: indexPath) as? SecondLegendCollectionViewCell {
            
            cell.listarEle(color: graphicColors[indexPath.row], nombre: legendValues[indexPath.row])

            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    

}

extension EstadoDeCuentaOrionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = 120 * collectionView.numberOfItems(inSection: 0)
        let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)

        let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
        let rightInset = leftInset

        return UIEdgeInsets(top: 10, left: leftInset, bottom: 0, right: rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let label = UILabel(frame: CGRect.zero)
        label.text = legendValues[indexPath.row]
        label.sizeToFit()
        return CGSize(width: label.frame.width + 20, height: 20)
    }
}
