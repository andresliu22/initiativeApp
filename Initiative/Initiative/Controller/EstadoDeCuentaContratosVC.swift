//
//  EstadoDeCuentaContratosVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/30/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class EstadoDeCuentaContratosVC: UIViewController {

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
            bottomBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tabContratos.layer.addSublayer(bottomBorder)
        }
    }
    
    @IBOutlet weak var tabOrion: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabOrion.frame.size.height - 2, width: tabOrion.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            tabOrion.layer.addSublayer(bottomBorder)
        }
    }
    
    @IBOutlet weak var buttonProvider: UIButton!
    @IBOutlet weak var buttonYear: UIButton!
    
    @IBOutlet weak var consumoView: UIView!
    
    @IBOutlet weak var gaugeView: UIView!
    @IBOutlet weak var consumoAnualLabel: UILabel!
    @IBOutlet weak var graphView: UIView!
    
    var arrayProvider = [Int]()
    var arrayYear = [Int]()
    
    var providerList = [FilterBody]()
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
    var gaugeValue = 0
    var graphData = [GraphElement]()
    var gaugeGraph = GaugeView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
    
    var graphicColors: [UIColor] = [UIColor(rgb: 0x7F2246), UIColor(rgb: 0xD93251), UIColor(rgb: 0x3F7F91), UIColor(rgb: 0x2C274C), UIColor(rgb: 0x3F7791), UIColor(rgb: 0x42173E), UIColor(rgb: 0xA3294A), UIColor(rgb: 0x37547F)]
    let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    
    let monthsInitials = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Dic"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        consumoView.layer.cornerRadius = 10
        
        buttonProvider.addBorders(width: 1)
        buttonYear.addBorders(width: 1)
        
        buttonProvider.titleEdgeInsets.left = 10
        buttonYear.titleEdgeInsets.left = 10
        
        buttonProvider.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        buttonYear.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
    
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(CellClass.self, forCellReuseIdentifier: "ImplementacionCell")

        self.searchBar.delegate = self
        self.tableView.reloadData()
        
        getProviders()
        getFilters()
        
        gaugeGraph.value = gaugeValue
        gaugeGraph.backgroundColor = .clear
        gaugeView.addSubview(gaugeGraph)
        
    }
    
    func getProviders(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.estadoCuentaContractProvidersURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay datos de proveedores")
                    return
                }
                for provider in jsonData["providerList"].arrayValue {
                    let isContained = self.providerList.contains { $0.id == provider["idProvider"].int! }
                    
                    if !isContained {
                        let newProvider: FilterBody = FilterBody(id: provider["idProvider"].int!, name: provider["name"].string!)
                        self.providerList.append(newProvider)
                    }
                    
                }
                self.arrayProvider.append(self.providerList[0].id)
                self.buttonProvider.setTitle(
                    "\(self.providerList[0].name)", for: .normal)
                self.getBarChart()
            } else {
                print("Failure")
            }
        })
    }
    
    func getFilters() {
        yearList = NetworkManager.shared.getYears()
//        for i in 0..<yearList.count {
//            arrayYear.append(yearList[i].id)
//        }
        arrayYear.append(yearList[yearList.count - 1].id)
        buttonYear.setTitle(yearList[yearList.count - 1].name, for: .normal)
    }
    
    func getBarChart() {
        self.graphData.removeAll()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idProvider": arrayProvider[0], "year": arrayYear[0], "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        
        serverManager.serverCallWithHeaders(url: serverManager.estadoCuentaContratoURL, params: parameters, method: .post, callback: { [self]  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                let data = jsonData["contract"]
                for i in 0..<12 {
                    let element = GraphElement(name: self.months[i], amount: 0.0)
                    self.graphData.append(element)
                }
                    
                var currentValueQ = ""
                if data["currentValue"].float! < 1000 {
                    currentValueQ = "$ \(String(format: "%.2f", data["currentValue"].float!))"
                } else if data["currentValue"].float! < 1000000 {
                    currentValueQ = "$ \(String(format: "%.2f", data["currentValue"].float!/1000))K"
                } else {
                    currentValueQ = "$ \(String(format: "%.2f", data["currentValue"].float!/1000000))MM"
                }
                
                var expectedValueQ = ""
                if data["expectedValue"].float! < 1000 {
                    expectedValueQ = "$ \(String(format: "%.2f", data["expectedValue"].float!))"
                } else if data["expectedValue"].float! < 1000000 {
                    expectedValueQ = "$ \(String(format: "%.2f", data["expectedValue"].float!/1000))K"
                } else {
                    expectedValueQ = "$ \(String(format: "%.2f", data["expectedValue"].float!/1000000))MM"
                }
                
                self.consumoAnualLabel.text = "\(currentValueQ) / \(expectedValueQ)"
                self.gaugeValue = Int(data["currentValue"].float!/data["expectedValue"].float! * 100)
                
                if self.gaugeValue > 100 {
                    self.gaugeValue = 100
                }
                
                for mes in data["months"].arrayValue {
                    let index = self.graphData.firstIndex(where: { $0.name.caseInsensitiveCompare(mes["name"].string!) == .orderedSame })
                    self.graphData[Int(index!)].amount += mes["amount"].float!

                }
                    
                self.graphData = self.graphData.filter{ $0.amount > 0}
                print(self.graphData)
                print(self.graphData.count)
                
                self.clearGraphView()
                gaugeGraph.value = gaugeValue
                gaugeGraph.valueArea = gaugeValue
                gaugeGraph.setNeedsDisplay()
                self.showBarChart(dataPoints: self.monthsInitials)
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    
    func showBarChart(dataPoints: [String]) {
        if self.graphData.count > 0 {
//            let formatter = BarChartFormatter()
//            formatter.setValues(values: dataPoints)
//            let bottomLabelsAxis: XAxis = XAxis()
//            bottomLabelsAxis.valueFormatter = formatter

            self.barChart.frame = CGRect(x: 10, y: 5, width: self.graphView.frame.size.width - 20, height: self.graphView.frame.height - 20)

            let yaxis = self.barChart.leftAxis
            yaxis.drawGridLinesEnabled = false
            yaxis.labelTextColor = UIColor.clear
            yaxis.axisLineColor = UIColor.clear
            yaxis.labelPosition = .insideChart
            yaxis.enabled = true
            yaxis.axisMinimum = 0
            self.barChart.rightAxis.enabled = false

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
            xaxis.drawGridLinesEnabled = false
            xaxis.valueFormatter = IndexAxisValueFormatter(values: self.monthsInitials)
            
            self.graphView.addSubview(self.barChart)

            var entries = [BarChartDataEntry]()
            
            
            for x in 0..<graphData.count {
                

                entries.append(BarChartDataEntry(x: Double(x), y: Double(graphData[x].amount / 1000).round(to: 2)))
            }
            
            let set = BarChartDataSet(values: entries, label: "1")
            set.drawValuesEnabled = false
            set.colors = [UIColor(rgb: 0x365381)]
            
            set.valueColors = [.black]
            set.valueLabelAngle = -90
            
            let barChartRenderer = BarChartEstadoDeCuentaContratosRenderer(dataProvider: barChart, animator: barChart.chartAnimator, viewPortHandler: barChart.viewPortHandler)
            barChart.renderer = barChartRenderer
            
            let chartData = BarChartData(dataSet: set)
            
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .currency
            pFormatter.maximumFractionDigits = 0
            pFormatter.multiplier = 1.0
            //pFormatter.zeroSymbol = ""
            pFormatter.currencySymbol = "$"
            pFormatter.positiveSuffix = "K"
            chartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
            chartData.barWidth = Double(0.4)
            chartData.setDrawValues(true)
            
            self.barChart.data = chartData
            self.barChart.data?.setValueFont(UIFont(name: "Aldine721BT-Roman",
                                                    size: 12.0)!)
            self.barChart.chartDescription.enabled = false
            self.barChart.legend.enabled = false
            self.barChart.rightAxis.enabled = false
            self.barChart.drawValueAboveBarEnabled = true
            self.barChart.notifyDataSetChanged()
            self.barChart.setVisibleXRangeMaximum(8)
            self.barChart.animate(yAxisDuration: 1.0, easingOption: .linear)
            self.barChart.doubleTapToZoomEnabled = false
            self.barChart.extraTopOffset = 30.0
            self.barChart.highlightPerTapEnabled = false
            chartData.setValueTextColor(UIColor.black)
            
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
            if arrayProvider.isEmpty {
                arrayProvider = arrayBeforeFilter
            }
            if arrayYear.isEmpty {
                arrayYear = arrayBeforeFilter
            }
            print("No hubo cambio en filtro")
        }
    }
    
    @IBAction func onClickBtnProvider(_ sender: UIButton) {
        dataSource = providerList
        selectedButton = buttonProvider
        arrayBeforeFilter = arrayProvider
        arrayProvider.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "proveedor...")
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
        let vc =  self.navigationController?.viewControllers.filter({$0 is EstadoDeCuentaProyectadoVC}).first
        self.navigationController?.popToViewController(vc!, animated: false)
    }
    @IBAction func goToOrion(_ sender: UIButton) {
        if let vc =  self.navigationController?.viewControllers.filter({$0 is EstadoDeCuentaOrionVC}).first {
            self.navigationController?.popToViewController(vc, animated: false)
        } else {
            performSegue(withIdentifier: "fromContratoToOrion", sender: self)
        }
    }
    
    @IBAction func returnToListado(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}


extension EstadoDeCuentaContratosVC: UITableViewDataSource {
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
            case buttonProvider:
                arrayValues = arrayProvider
            case buttonYear:
                arrayValues = arrayYear
            default:
                arrayValues = arrayProvider
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
            case buttonProvider:
                arrayProvider = arrayValues
            case buttonYear:
                arrayYear = arrayValues
            default:
                arrayProvider = arrayValues
        }
        
        didSelect = true
        print(arrayValues)
        removeTransparentView()
        
    }
    
}

extension EstadoDeCuentaContratosVC: UITableViewDelegate {
    
}

extension EstadoDeCuentaContratosVC: UISearchBarDelegate {
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
            case buttonProvider:
                arrayProvider.removeAll()
            case buttonYear:
                arrayYear.removeAll()
            default:
                arrayProvider.removeAll()
        }
    }
}
