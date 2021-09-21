//
//  EstadoDeCuentaProyectadoVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/30/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class EstadoDeCuentaProyectadoVC: UIViewController {

    
    @IBOutlet weak var tabProyectado: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabProyectado.frame.size.height - 2, width: tabProyectado.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
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
            bottomBorder.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            tabOrion.layer.addSublayer(bottomBorder)
        }
    }
    
    @IBOutlet weak var fullYearView: UIView!
    @IBOutlet weak var ytdView: UIView!
    @IBOutlet weak var fullYearValue: UILabel!
    @IBOutlet weak var ytdValue: UILabel!
    
    
    @IBOutlet weak var buttonMedia: UIButton!
    
    @IBOutlet weak var buttonProvider: UIButton!
    
    @IBOutlet weak var buttonVehicle: UIButton!
    
    @IBOutlet weak var graphView: UIView!
    
    var arrayMedia = [Int]()
    var arrayProvider = [Int]()
    var arrayVehicle = [Int]()
    
    var mediaList = [FilterBody]()
    var providerList = [FilterBody]()
    var vehicleList = [FilterBody]()
    
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
    
    var graphData = [EstadoCuentaProyectadoStruct]()
    
    var graphicColors: [UIColor] = [UIColor(rgb: 0x365381), UIColor(rgb: 0xD0173D)]
    let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    
    let monthsInitials = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Dic"]
    let legendValues = ["Consumido", "Pagado"]
    
    @IBOutlet weak var legendCV: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        fullYearView.layer.cornerRadius = 10
        ytdView.layer.cornerRadius = 10
        
        buttonMedia.addBorders(width: 1)
        buttonProvider.addBorders(width: 1)
        buttonVehicle.addBorders(width: 1)
        
        buttonMedia.titleEdgeInsets.left = 10
        buttonProvider.titleEdgeInsets.left = 10
        buttonVehicle.titleEdgeInsets.left = 10
        
        buttonMedia.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        buttonProvider.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        buttonVehicle.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        addLineBorder()
        getMedia()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(CellClass.self, forCellReuseIdentifier: "InversionCell")
        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        self.searchBar.delegate = self
        
        self.legendCV.dataSource = self
        self.legendCV.delegate = self
        self.tableView.reloadData()
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
    func getMedia(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.mediaURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay datos de medios")
                    return
                }
                for media in jsonData["mediaInversionList"].arrayValue {
                    let newMedia: FilterBody = FilterBody(id: media["id"].int!, name: media["name"].string!)
                    self.mediaList.append(newMedia)
                    self.arrayMedia.append(newMedia.id)
                }
                self.getProviders()
            } else {
                print("Failure")
            }
        })
    }
    
    func getProviders(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.estadoCuentaProvidersURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
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
                        self.arrayProvider.append(newProvider.id)
                    }
                }
                self.getVehicle()
            } else {
                print("Failure")
            }
        })
    }
    
    func getVehicle(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.vehicleURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay datos de vehículos")
                    return
                }
                for vehicle in jsonData["vehicleInversionList"].arrayValue {
                    let newVehicle: FilterBody = FilterBody(id: vehicle["idVehicle"].int!, name: vehicle["name"].string!)
                    self.vehicleList.append(newVehicle)
                    self.arrayVehicle.append(newVehicle.id)
                }
                self.getBarChart()
            } else {
                print("Failure")
            }
        })
    }
    
    func getBarChart() {
        self.graphData.removeAll()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["medias": arrayMedia, "providers": arrayProvider, "vihicles": arrayVehicle, "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
//        let parameters : Parameters  = ["medias": [1,2,3,4,5,6,7,8,9], "providers": [1,4,6,32,75,144,429,569], "vihicles": [5,4,3,1,3276,2828,3388,1668], "idCurrency": 2, "idBrand": 596]
        
        serverManager.serverCallWithHeaders(url: serverManager.estadoCuentaProyectadoURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                let data = jsonData["projected"]
                for i in 0..<12 {
                    let element = EstadoCuentaProyectadoStruct(name: self.months[i], consumido: 0.0, pagado: 0.0)
                    self.graphData.append(element)
                }
                
                var fullYearQ = ""
                if data["fullYear"].float! < 1000 {
                    fullYearQ = "$ \(String(format: "%.2f", data["fullYear"].float!))"
                } else if data["fullYear"].float! < 1000000 {
                    fullYearQ = "$ \(String(format: "%.2f", data["fullYear"].float!/1000))K"
                } else {
                    fullYearQ = "$ \(String(format: "%.2f", data["fullYear"].float!/1000000))MM"
                }
                self.fullYearValue.text = fullYearQ
                
                var ytdQ = ""
                if data["ytd"].float! < 1000 {
                    ytdQ = "$ \(String(format: "%.2f", data["ytd"].float!))"
                } else if data["ytd"].float! < 1000000 {
                    ytdQ = "$ \(String(format: "%.2f", data["ytd"].float!/1000))K"
                } else {
                    ytdQ = "$ \(String(format: "%.2f", data["ytd"].float!/1000000))MM"
                }
                self.ytdValue.text = ytdQ
                
                
                for mes in data["months"].arrayValue {
                    for car in mes["cars"].arrayValue {
                        let index = self.graphData.firstIndex(where: { $0.name.caseInsensitiveCompare(mes["name"].string!) == .orderedSame })
                        if car["name"].string!.caseInsensitiveCompare("CONSUMO") == .orderedSame {
                            self.graphData[Int(index!)].consumido += car["amount"].float!
                        } else if car["name"].string!.caseInsensitiveCompare("PAGADO") == .orderedSame {
                            self.graphData[Int(index!)].pagado += car["amount"].float!
                        }
                    }
                }
                    
                
                //self.graphData = self.graphData.filter{ $0.consumido > 0}
                print(self.graphData)
                print(self.graphData.count)
                self.showBarChart(dataPoints: self.monthsInitials)
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func showBarChart(dataPoints: [String]) {
        if self.graphData.count > 0 {
            clearGraphView()

            self.barChart.frame = CGRect(x: 10, y: 5, width: self.graphView.frame.size.width, height: self.graphView.frame.height - 10)

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
                entries.append(BarChartDataEntry(x: Double(x), y: Double(graphData[x].consumido / 1000000).round(to: 2)))
                entries2.append(BarChartDataEntry(x: Double(x), y: Double(graphData[x].pagado / 1000000).round(to: 2)))
            }
            
            let set = BarChartDataSet(values: entries, label: "1")
            let set2 = BarChartDataSet(values: entries2, label: "2")
            
            set.drawValuesEnabled = false
            set.colors = [UIColor(rgb: 0x365381)]
            //set.highlightColor = UIColor(rgb: 0x365381)
            set.valueColors = [.black]
            set.valueLabelAngle = -90
            
            set2.drawValuesEnabled = false
            set2.colors = [UIColor(rgb: 0xD0173D)]
            //set2.highlightColor = UIColor(rgb: 0xD0173D)
            set2.valueColors = [.black]
            set2.valueLabelAngle = -90
            
            let barChartRenderer = BarChartEstadoDeCuentaRenderer(dataProvider: barChart, animator: barChart.chartAnimator, viewPortHandler: barChart.viewPortHandler)
            barChart.renderer = barChartRenderer
            
            var datasets = [BarChartDataSet]()
            datasets.append(set)
            datasets.append(set2)
            
            let chartData = BarChartData(dataSets: datasets)
            chartData.setDrawValues(true)
            chartData.setValueTextColor(UIColor.black)
            
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .currency
            pFormatter.maximumFractionDigits = 2
            pFormatter.multiplier = 1.0
            //pFormatter.zeroSymbol = ""
            pFormatter.currencySymbol = "$"
            pFormatter.positiveSuffix = "MM"
            chartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
            
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
            barChart.highlightPerTapEnabled = false
            self.legendCV.reloadData()
            
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
            if arrayMedia.isEmpty {
                arrayMedia = arrayBeforeFilter
            }
            if arrayProvider.isEmpty {
                arrayProvider = arrayBeforeFilter
            }
            if arrayVehicle.isEmpty {
                arrayVehicle = arrayBeforeFilter
            }
            print("No hubo cambio en filtro")
        }
    }
    
    @IBAction func onClickBtnMedia(_ sender: UIButton) {
        dataSource = mediaList
        selectedButton = buttonMedia
        arrayBeforeFilter = arrayMedia
        arrayMedia.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "medio...")
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
    
    @IBAction func onClickBtnVehicle(_ sender: UIButton) {
        dataSource = vehicleList
        selectedButton = buttonVehicle
        arrayBeforeFilter = arrayVehicle
        arrayVehicle.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "vehículo...")
    }
    
    @IBAction func returnToListado(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func goToContratos(_ sender: UIButton) {
        performSegue(withIdentifier: "goToContratos", sender: self)
    }
    
    @IBAction func goToOrion(_ sender: UIButton) {
        performSegue(withIdentifier: "goToOrion", sender: self)
    }
}

extension EstadoDeCuentaProyectadoVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return dataSearch.count + 1
        } else {
            return dataSource.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InversionCell", for: indexPath)
        
        cell.textLabel?.font = UIFont(name: "Aldine721BT-Roman",
                                      size: 15.0)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Todos"
        } else {
            if searching {
                cell.textLabel?.text = dataSearch[indexPath.row - 1].name
            } else {
                cell.textLabel?.text = dataSource[indexPath.row - 1].name
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var arrayValues = [Int]()
        
        switch (selectedButton) {
            case buttonMedia:
                arrayValues = arrayMedia
            case buttonProvider:
                arrayValues = arrayProvider
            case buttonVehicle:
                arrayValues = arrayVehicle
            default:
                arrayValues = arrayMedia
        }
        
        var valueSelected: FilterBody
        if indexPath.row == 0 {
            valueSelected = FilterBody(id: -1, name: "Todos")
        } else {
            if searching {
                valueSelected = FilterBody(id: dataSearch[indexPath.row - 1].id, name: dataSearch[indexPath.row - 1].name)
            } else {
                valueSelected = FilterBody(id: dataSource[indexPath.row - 1].id, name: dataSource[indexPath.row - 1].name)
            }
        }
    
        if valueSelected.id == -1 {
            for section in 0..<tableView.numberOfSections {
                for row in 0..<tableView.numberOfRows(inSection: section) {
                    let indexPath = IndexPath(row: row, section: section)
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
            arrayValues.removeAll()
            for i in 0..<dataSource.count {
                arrayValues.append(dataSource[i].id)
            }
        } else {
            arrayValues.append(valueSelected.id)
        }
        
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
            case buttonMedia:
                arrayMedia = arrayValues
            case buttonProvider:
                arrayProvider = arrayValues
            case buttonVehicle:
                arrayVehicle = arrayValues
            default:
                arrayMedia = arrayValues
        }
        
        didSelect = true
    
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        var arrayValues = [Int]()
        switch (selectedButton) {
            case buttonMedia:
                arrayValues = arrayMedia
            case buttonProvider:
                arrayValues = arrayProvider
            case buttonVehicle:
                arrayValues = arrayVehicle
            default:
                arrayValues = arrayMedia
        }
        var valueSelected: FilterBody
        if indexPath.row == 0 {
            valueSelected = FilterBody(id: -1, name: "Todos")
        } else {
            if searching {
                valueSelected = FilterBody(id: dataSearch[indexPath.row - 1].id, name: dataSearch[indexPath.row - 1].name)
            } else {
                valueSelected = FilterBody(id: dataSource[indexPath.row - 1].id, name: dataSource[indexPath.row - 1].name)
            }
        }
        
        if valueSelected.id == -1 {
            for section in 0..<tableView.numberOfSections {
                for row in 0..<tableView.numberOfRows(inSection: section) {
                    let indexPath = IndexPath(row: row, section: section)
                    tableView.deselectRow(at: indexPath, animated: false)
                }
            }
            arrayValues.removeAll()
        } else {
            arrayValues = arrayValues.filter(){$0 != valueSelected.id}
        }
        
        
        if arrayValues.count == 1 {
            let nameLeft: [FilterBody] = dataSource.filter(){$0.id == arrayValues[0]}
            selectedButton.setTitle(nameLeft[0].name, for: .normal)
        } else if arrayValues.count > 1 && arrayValues.count < dataSource.count {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.deselectRow(at: indexPath, animated: false)
            selectedButton.setTitle("Varios", for: .normal)
        } else if arrayValues.count >= dataSource.count {
            selectedButton.setTitle("Todos", for: .normal)
        } else if arrayValues.count == 0 {
            didSelect = false
        }
        
        switch (selectedButton) {
            case buttonMedia:
                arrayMedia = arrayValues
            case buttonProvider:
                arrayProvider = arrayValues
            case buttonVehicle:
                arrayVehicle = arrayValues
            default:
                arrayMedia = arrayValues
        }
    }
}

extension EstadoDeCuentaProyectadoVC: UITableViewDelegate {
    
}

extension EstadoDeCuentaProyectadoVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        dataSearch = dataSource.filter({$0.name.uppercased().contains(searchText.uppercased())})
        if searchText != "" {
            searching = true
        } else {
            searching = false
        }
        tableView.reloadData()
        var arrayValues = [Int]()
        
        switch (selectedButton) {
            case buttonMedia:
                arrayValues = arrayMedia
            case buttonProvider:
                arrayValues = arrayProvider
            case buttonVehicle:
                arrayValues = arrayVehicle
            default:
                arrayValues = arrayMedia
        }
        
        var arrayNames = [String]()
        for i in 0..<arrayValues.count {
            let index = dataSource.firstIndex(where: { $0.id == arrayValues[i]})
            arrayNames.append(dataSource[Int(index!)].name)
        }
        
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if arrayNames.contains(tableView.cellForRow(at: indexPath)?.textLabel?.text ?? "-999") {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        switch (selectedButton) {
            case buttonMedia:
                arrayMedia.removeAll()
            case buttonProvider:
                arrayProvider.removeAll()
            case buttonVehicle:
                arrayVehicle.removeAll()
            default:
                arrayMedia.removeAll()
        }
    }
}

extension EstadoDeCuentaProyectadoVC: UICollectionViewDataSource {
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

extension EstadoDeCuentaProyectadoVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let totalCellWidth = 100 * collectionView.numberOfItems(inSection: 0)
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
