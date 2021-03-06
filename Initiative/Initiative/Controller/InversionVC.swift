//
//  InversionVC.swift
//  Initiative
//
//  Created by Andres Liu on 10/28/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class CellClass: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
}

class InversionVC: UIViewController, ChartViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var buttonCurrentBrand: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: buttonCurrentBrand.frame.size.height - 2, width: buttonCurrentBrand.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            buttonCurrentBrand.layer.addSublayer(bottomBorder)
        }
    }
    
    @IBOutlet weak var buttonAdBrand: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: buttonAdBrand.frame.size.height - 2, width: buttonAdBrand.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            buttonAdBrand.layer.addSublayer(bottomBorder)
        }
    }
    
    @IBOutlet weak var buttonYear: UIButton!
    @IBOutlet weak var buttonMonth: UIButton!
    @IBOutlet weak var buttonMedia: UIButton!
    @IBOutlet weak var buttonProvider: UIButton!
    @IBOutlet weak var buttonCampaign: UIButton!
    @IBOutlet weak var buttonPresetMenu: UIButton!
    
    let transparentView = UIView()
    let borderView = UIView()
    let inBetweenView = UIView()
    let searchBar = UISearchBar()
    let tableView = UITableView()
    var selectedButton = UIButton()
    let presetMenuTableView = UITableView()
    
    var lineChart = LineChartView()
    var barChart = BarChartView()
    var pieChart = PieChartView()
    let pieChartTopLabel = UILabel()
    let pieChartCenterLabel = UILabel()
    let pieChartBottomLabel = UILabel()
    
    var dataSource = [FilterBody]()
    var dataSearch = [FilterBody]()
    var searching = false
    var didSelect = false
    
    var totalAmount: Float = 0.0
    var graphData = [GraphElement]()
    var arrayOfGraphData = [[GraphElement]]()
    
    var graphData2 = [GraphElement2]()
    var arrayOfGraphData2 = [[GraphElement2]]()
    
    var arrayYear = [Int]()
    var arrayMonth = [Int]()
    var arrayMedia = [Int]()
    var arrayProvider = [Int]()
    var arrayCampaign = [Int]()
    
    var arrayBeforeFilter = [Int]()
    
    var yearList = [FilterBody]()
    var monthList = [FilterBody]()
    var providerList = [FilterBody]()
    var mediaList = [FilterBody]()
    var campaignList = [FilterBody]()
    
    var idCurrency = 1
    var numGraph = 2
    
    let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    let monthsUppCase = ["ENERO", "FEBRERO", "MARZO", "ABRIL", "MAYO", "JUNIO", "JULIO", "AGOSTO", "SEPTIEMBRE", "OCTUBRE", "NOVIEMBRE", "DICIEMBRE"]
    let monthsInitials = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Dic"]
    var allYears = [String]()
    
    let presetMenuOptions = ["LIMPIAR TODOS LOS FILTROS", "GUARDAR PRESET"]
    @IBOutlet weak var contentView: UIView!
    
    
    @IBOutlet weak var graphView: UIView!
    
    var graphicColors: [UIColor] = [UIColor(rgb: 0x7F2246), UIColor(rgb: 0xD93251), UIColor(rgb: 0x3F7F91), UIColor(rgb: 0x2C274C), UIColor(rgb: 0x3F7791), UIColor(rgb: 0x42173E), UIColor(rgb: 0xA3294A), UIColor(rgb: 0x37547F), UIColor(rgb: 0x49302f), UIColor(rgb: 0xD93251), UIColor(rgb: 0x3F7F91), UIColor(rgb: 0x2C274C), UIColor(rgb: 0x3F7791), UIColor(rgb: 0x42173E), UIColor(rgb: 0xA3294A), UIColor(rgb: 0x37547F), UIColor(rgb: 0x7F2246), UIColor(rgb: 0xD93251), UIColor(rgb: 0x3F7F91), UIColor(rgb: 0x2C274C), UIColor(rgb: 0x3F7791), UIColor(rgb: 0x42173E), UIColor(rgb: 0xA3294A), UIColor(rgb: 0x37547F), UIColor(rgb: 0x7F2246), UIColor(rgb: 0xD93251), UIColor(rgb: 0x3F7F91), UIColor(rgb: 0x2C274C), UIColor(rgb: 0x3F7791), UIColor(rgb: 0x42173E), UIColor(rgb: 0xA3294A), UIColor(rgb: 0x37547F), UIColor(rgb: 0x7F2246), UIColor(rgb: 0xD93251), UIColor(rgb: 0x3F7F91), UIColor(rgb: 0x2C274C), UIColor(rgb: 0x3F7791), UIColor(rgb: 0x42173E), UIColor(rgb: 0xA3294A), UIColor(rgb: 0x37547F)]
    
    
    @IBOutlet weak var firstLegend: UICollectionView!
    
    @IBOutlet weak var secondLegend: UICollectionView!
    
    var arrayVacio = true
    
    @IBOutlet weak var secondLegendHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(CellClass.self, forCellReuseIdentifier: "InversionCell")
        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        self.presetMenuTableView.delegate = self
        self.presetMenuTableView.dataSource = self
        
        self.searchBar.delegate = self
        
        self.firstLegend.dataSource = self
        self.firstLegend.delegate = self
        
        self.secondLegend.dataSource = self
        self.secondLegend.delegate = self
        
//        let layout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        layout.itemSize = CGSize(width: 100, height: 300)
//        layout.scrollDirection = .horizontal
        
        buttonCurrentBrand.setTitle(UserDefaults.standard.string(forKey: "brandName"), for: .normal)
        buttonYear.addBorders(width: 1)
        buttonMonth.addBorders(width: 1)
        buttonMedia.addBorders(width: 1)
        buttonProvider.addBorders(width: 1)
        buttonCampaign.addBorders(width: 1)
        
        buttonYear.titleEdgeInsets.left = 10
        buttonMonth.titleEdgeInsets.left = 10
        buttonMedia.titleEdgeInsets.left = 10
        buttonProvider.titleEdgeInsets.left = 10
        buttonCampaign.titleEdgeInsets.left = 10
        
        buttonYear.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        buttonMonth.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        buttonMedia.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        buttonProvider.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        buttonCampaign.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        getFilters()
        
        self.tableView.reloadData()
        self.presetMenuTableView.reloadData()
        
        addLineBorder(lineView: contentView, height: contentView.frame.height)
        addLineBorder(lineView: secondLegend, height: 0.0)
        
        
    }
    
    func addLineBorder(lineView: UIView, height: CGFloat) {
        let topLayer = CALayer()
        topLayer.frame = CGRect(x: 30.0, y: height, width: self.view.frame.width - 60.0 , height: 1.0)

        let topBorder = CAShapeLayer()
        topBorder.strokeColor = UIColor.black.cgColor
        topBorder.lineWidth = 1
        topBorder.lineDashPattern = [2, 2]
        topBorder.frame = topLayer.bounds
        topBorder.fillColor = nil
        topBorder.path = UIBezierPath(rect: topLayer.bounds).cgPath
        
        topLayer.addSublayer(topBorder)
        lineView.layer.addSublayer(topLayer)
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
                    
                    if self.arrayVacio {
                        self.arrayMedia.append(newMedia.id)
                    }
                }
                if !self.arrayVacio {
                    self.changeButtonTitle(self.buttonMedia, self.arrayMedia, self.mediaList)
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
        serverManager.serverCallWithHeaders(url: serverManager.providerURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
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
                        
                        if self.arrayVacio {
                            self.arrayProvider.append(newProvider.id)
                        }
                    }
                }
                if !self.arrayVacio {
                    self.changeButtonTitle(self.buttonProvider, self.arrayProvider, self.providerList)
                }
                self.getCampaign()
            } else {
                print("Failure")
            }
        })
    }
    
    public func getCampaign(){
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        serverManager.serverCallWithHeaders(url: serverManager.campaignListURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.validateEntryData(title: "Error", message: "No hay datos de campa??as")
                    return
                }
                for campaign in jsonData["campaignList"].arrayValue {
                    let isContained = self.campaignList.contains { $0.id == campaign["idCampaign"].int! }
                    
                    if !isContained {
                        let newCampaign: FilterBody = FilterBody(id: campaign["idCampaign"].int!, name: campaign["name"].string!)
                        self.campaignList.append(newCampaign)
                        
                        if self.arrayVacio {
                            self.arrayCampaign.append(newCampaign.id)
                        }
                    }
                }
                if !self.arrayVacio {
                    self.changeButtonTitle(self.buttonCampaign, self.arrayCampaign, self.campaignList)
                }
                self.showChart()
            } else {
                print("Failure")
            }
        })
    }
    
    func getFilters() {
        
        yearList = NetworkManager.shared.getYears()
        monthList = NetworkManager.shared.getMonths()
        
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        for i in 0..<yearList.count {
            allYears.append(yearList[i].name)
//            if arrayVacio {
//                arrayYear.append(yearList[i].id)
//            }
        }
        
//        arrayMonth.append(month)
        if arrayVacio {
//            for i in 0..<monthList.count {
//                arrayMonth.append(monthList[i].id)
//            }
            arrayYear.append(year)
            arrayMonth.append(month)

        } else {
            changeButtonTitle(buttonYear, arrayYear, yearList)
            changeButtonTitle(buttonMonth, arrayMonth, monthList)
        }
        buttonYear.setTitle("\(year)", for: .normal)
        buttonMonth.setTitle("\(monthList[month - 1].name)", for: .normal)
        getMedia()
    }
    
    func changeButtonTitle(_ button: UIButton, _ arrayFilter: [Int], _ list: [FilterBody]) {
        if arrayFilter.count <= 1 {
            if arrayFilter == arrayYear {
                button.setTitle("\(arrayFilter[0])", for: .normal)
            } else if arrayFilter == arrayMonth {
                button.setTitle(list[arrayFilter[0] - 1].name, for: .normal)
            } else if arrayFilter == arrayMedia {
                button.setTitle(list[arrayFilter[0] - 1].name, for: .normal)
            } else {
                let filterList = list.filter(){$0.id == arrayFilter[0]}
                button.setTitle(filterList[0].name, for: .normal)
            }
            
        } else if arrayFilter.count < list.count {
            button.setTitle("Varios", for: .normal)
        } else {
            button.setTitle("Todos", for: .normal)
        }
    }
    
    func showChart() {
        if (arrayMonth.count > 1 && arrayMedia.count == 1 && arrayProvider.count == 1) {
            // Grafico de Linea
            print("Grafico de Linea")
            numGraph = 1
            getLineChart()
        } else if (arrayMonth.count > 1 && arrayMedia.count > 1) {
            //Grafico de Barras - Medios
            print("Grafico de Barras - Medios")
            numGraph = 2
            getBarChartMedia()
        } else if (arrayMonth.count > 1 && arrayMedia.count == 1) {
            //Grafico de Barras - Proveedor
            print("Grafico de Barras - Proveedor")
            numGraph = 3
            getBarChartProvider()
        } else if (arrayMonth.count == 1 && arrayMedia.count > 1) {
            //Grafico de Pie - Medios
            print("Grafico de Pie - Medios")
            numGraph = 4
            getPieChartMedia()
        } else if (arrayMonth.count == 1 && arrayMedia.count == 1) {
            //Grafico de Pie - Proveedor
            print("Grafico de Pie - Proveedor")
            numGraph = 5
            getPieChartProvider()
        }
    }

    // MARK: - BARCHART MEDIA
    func getBarChartMedia() {
        
        clearGraphView()
        self.arrayOfGraphData.removeAll()
        self.graphData.removeAll()
        
        let serverManager = ServerManager()
        let parameters : Parameters  = ["years": arrayYear, "months": arrayMonth, "medias": arrayMedia, "providers": arrayProvider, "campaigns": arrayCampaign, "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        
        serverManager.serverCallWithHeaders(url: serverManager.inversionURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                print(jsonData)
                self.graphData2.removeAll()
                let inversion = jsonData["inversion"]
                var dateType = 1
                var years = inversion["years"].arrayValue
                years.sort { $0["num"].int! < $1["num"].int! }
                for year in years {
                    if self.arrayYear.count > 1 {
                        dateType = 1
                        for i in 0..<self.yearList.count {
                            let element = GraphElement2(timestamp: self.yearList[i].name, amount: 0.0)
                            self.graphData2.append(element)
                        }
                        var graphElement2 = GraphElement2(timestamp: String(year["num"].int!), amount: 0.0)
                        self.graphData.removeAll()
                        for i in 0..<self.arrayMedia.count {
                            let nameLeft: [FilterBody] = self.mediaList.filter(){$0.id == self.arrayMedia[i]}
                            let element: GraphElement = GraphElement(name: nameLeft[0].name, amount: 0.0)
                            self.graphData.append(element)
                        }
                        for mes in year["months"].arrayValue {
                            for media in mes["media"].arrayValue {
                                for provider in media["providers"].arrayValue {
                                    let index = self.graphData.firstIndex(where: { $0.name == media["name"].string! })
                                    self.graphData[Int(index!)].amount += provider["amount"].float!
                                    graphElement2.amount += provider["amount"].float!
                                }
                            }
                        }
                        self.arrayOfGraphData.append(self.graphData)
                        let index = self.allYears.firstIndex(where: { $0.caseInsensitiveCompare(graphElement2.timestamp) == .orderedSame})
                        self.graphData2[Int(index!)].amount = graphElement2.amount
                        //self.graphData2.append(graphElement2)
                    } else {
                        dateType = 2
                        for i in 0..<12 {
                            let element = GraphElement2(timestamp: self.months[i], amount: 0.0)
                            self.graphData2.append(element)
                        }
                        
                        var meses = year["months"].arrayValue
                        var monthsChosen = [String]()
                        let monthsOrdered = self.arrayMonth.sorted { $0 < $1 }
                        for i in 0..<monthsOrdered.count {
                            monthsChosen.append(self.monthsUppCase[monthsOrdered[i] - 1])
                        }
                        meses.sort{ monthsChosen.firstIndex(of: $0["name"].string!)! < monthsChosen.firstIndex(of: $1["name"].string!)! }
                        for mes in meses {
                            print(mes)
                            var graphElement2 = GraphElement2(timestamp: mes["name"].string!, amount: 0.0)
                            self.graphData.removeAll()
                            for i in 0..<self.arrayMedia.count {
                                let nameLeft: [FilterBody] = self.mediaList.filter(){$0.id == self.arrayMedia[i]}
                                let element: GraphElement = GraphElement(name: nameLeft[0].name, amount: 0.0)
                                self.graphData.append(element)
                            }
                            for media in mes["media"].arrayValue {
                                for provider in media["providers"].arrayValue {
                                    let index = self.graphData.firstIndex(where: { $0.name == media["name"].string! })
                                    self.graphData[Int(index!)].amount += provider["amount"].float!
                                    graphElement2.amount += provider["amount"].float!
                                }
                            }
                            self.arrayOfGraphData.append(self.graphData)
                            let index = self.months.firstIndex(where: { $0.caseInsensitiveCompare(graphElement2.timestamp) == .orderedSame})
                            self.graphData2[Int(index!)].amount = graphElement2.amount
                        }
                    }
                }
                
//                if self.arrayYear.count > 1 {
//                    self.graphData2.sort{$0.timestamp < $1.timestamp}
//                } else {
//                    self.graphData2 = self.graphData2.filter{ $0.amount > 0}
//                }
                self.graphData2 = self.graphData2.filter{ $0.amount > 0}
                self.showBarChart(date: dateType, type: 1)
                self.firstLegend.reloadData()
                self.secondLegend.reloadData()
                
                let newHeight = self.secondLegend.collectionViewLayout.collectionViewContentSize.height
                self.secondLegendHeightConstraint.constant = newHeight
                self.view.setNeedsLayout()
                
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    // MARK: - BARCHART PROVEEDOR
    func getBarChartProvider() {
        
        guard arrayProvider.count < 9 else {
            showAlert(title: "Error", message: "Falta colocar un mensaje de error (exceso de proveedores)")
            return
        }
        
        clearGraphView()
        self.arrayOfGraphData.removeAll()
        self.graphData.removeAll()
        
        let serverManager = ServerManager()
        let parameters : Parameters  = ["years": arrayYear, "months": arrayMonth, "medias": arrayMedia, "providers": arrayProvider, "campaigns": arrayCampaign, "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        
        serverManager.serverCallWithHeaders(url: serverManager.inversionURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                self.graphData2.removeAll()
                let inversion = jsonData["inversion"]
                var dateType = 1
                var years = inversion["years"].arrayValue
                years.sort { $0["num"].int! < $1["num"].int! }
                
                for year in years {
                    if self.arrayYear.count > 1 {
                        dateType = 1
                        
                        for i in 0..<self.yearList.count {
                            let element = GraphElement2(timestamp: self.yearList[i].name, amount: 0.0)
                            self.graphData2.append(element)
                        }
                        var graphElement2 = GraphElement2(timestamp: String(year["num"].int!), amount: 0.0)
                        self.graphData.removeAll()
                        for i in 0..<self.arrayProvider.count {
                            let nameLeft: [FilterBody] = self.providerList.filter(){$0.id == self.arrayProvider[i]}
                            let element: GraphElement = GraphElement(name: nameLeft[0].name, amount: 0.0)
                            self.graphData.append(element)
                        }
                    
                        for mes in year["months"].arrayValue {
                            for media in mes["media"].arrayValue {
                                for provider in media["providers"].arrayValue {
                                    let index = self.graphData.firstIndex(where: { $0.name.caseInsensitiveCompare(provider["name"].string!) == .orderedSame })
                                    self.graphData[Int(index!)].amount += provider["amount"].float!
                                    graphElement2.amount += provider["amount"].float!
                                }
                            }
                        }
                        self.arrayOfGraphData.append(self.graphData)
                        let index = self.allYears.firstIndex(where: { $0.caseInsensitiveCompare(graphElement2.timestamp) == .orderedSame})
                        self.graphData2[Int(index!)].amount = graphElement2.amount
                        //self.graphData2.append(graphElement2)
                    } else {
                        dateType = 2
                        for i in 0..<12 {
                            let element = GraphElement2(timestamp: self.months[i], amount: 0.0)
                            self.graphData2.append(element)
                        }
                        var meses = year["months"].arrayValue
                        var monthsChosen = [String]()
                        let monthsOrdered = self.arrayMonth.sorted { $0 < $1 }
                        for i in 0..<monthsOrdered.count {
                            monthsChosen.append(self.monthsUppCase[monthsOrdered[i] - 1])
                        }
                        meses.sort{ monthsChosen.firstIndex(of: $0["name"].string!)! < monthsChosen.firstIndex(of: $1["name"].string!)! }
                        
                        for mes in meses {
                            var graphElement2 = GraphElement2(timestamp: mes["name"].string!, amount: 0.0)
                            self.graphData.removeAll()
                            for i in 0..<self.arrayProvider.count {
                                let nameLeft: [FilterBody] = self.providerList.filter(){$0.id == self.arrayProvider[i]}
                                let element: GraphElement = GraphElement(name: nameLeft[0].name, amount: 0.0)
                                self.graphData.append(element)
                            }
                            
                            for media in mes["media"].arrayValue {
                                for provider in media["providers"].arrayValue {
                                    let index = self.graphData.firstIndex(where: { $0.name == provider["name"].string! })
                                    self.graphData[Int(index!)].amount += provider["amount"].float!
                                    graphElement2.amount += provider["amount"].float!
                                }
                            }
                            self.arrayOfGraphData.append(self.graphData)
//                            self.graphData2.append(graphElement2)
                            let index = self.months.firstIndex(where: { $0.caseInsensitiveCompare(graphElement2.timestamp) == .orderedSame})
                            self.graphData2[Int(index!)].amount = graphElement2.amount
                        }
                    }
                }
                self.secondLegend.reloadData()
                let newHeight = self.secondLegend.collectionViewLayout.collectionViewContentSize.height
                self.secondLegendHeightConstraint.constant = newHeight
                self.view.setNeedsLayout()
                
                self.graphData2 = self.graphData2.filter{ $0.amount > 0}
                self.showBarChart(date: dateType, type: 2)
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
            
        })
    }
    
    func showBarChart(date: Int, type: Int) {
        if self.graphData.count > 0 {
            
            self.firstLegend.isHidden = true
            self.graphView.frame = CGRect(x: 0, y: 0, width: self.graphView.frame.size.width, height: self.graphView.frame.height + 80)
            clearGraphView()

            self.barChart.frame = CGRect(x: 10, y: 0, width: self.graphView.frame.size.width - 25, height: self.graphView.frame.height - 40)
            
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
            xaxis.centerAxisLabelsEnabled = true
            xaxis.granularity = 1
            
            graphView.addSubview(barChart)
            graphView.bringSubviewToFront(buttonPresetMenu)
            
            var datasets = [BarChartDataSet]()
            
            var quantity = 0
            if type == 1 {
                quantity = arrayMedia.count
            } else {
                quantity = arrayProvider.count
            }
            
            for i in 0..<quantity {
                var entries = [BarChartDataEntry]()
                for j in 0..<arrayOfGraphData.count {
                    entries.append(BarChartDataEntry(x: Double(j), y: Double(arrayOfGraphData[j][i].amount / 1000000).round(to: 2)))
                }
        
                let set = BarChartDataSet(values: entries, label: String(i))
                set.valueLabelAngle = -90
                set.drawValuesEnabled = false
                //set.colors = ChartColorTemplates.colorful()
                set.colors = [self.graphicColors[i]]
                set.valueColors = [.black]
                datasets.append(set)
            }
            
            var xaxisLabelArray = [String]()
            for i in 0..<graphData2.count {
                var monthTotalAmount = 0.0
                for j in 0..<quantity {
                    monthTotalAmount += Double(arrayOfGraphData[i][j].amount / 1000000).round(to:2)
                }
                xaxisLabelArray.append("$ \(String(format: "%.2f", monthTotalAmount))MM \n\(self.graphData2[i].timestamp)")
                
            }
            xaxis.valueFormatter = IndexAxisValueFormatter(values: xaxisLabelArray)
            
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .currency
            pFormatter.maximumFractionDigits = 2
            pFormatter.multiplier = 1.0
            //pFormatter.zeroSymbol = ""
            pFormatter.currencySymbol = "$"
            pFormatter.positiveSuffix = "MM"
            let chartData = BarChartData(dataSets: datasets)
            chartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
            chartData.setDrawValues(true)
            chartData.setValueTextColor(UIColor.black)
            
            let barChartRenderer = BarChartAboveBarValueRenderer(dataProvider: barChart, animator: barChart.chartAnimator, viewPortHandler: barChart.viewPortHandler)
            barChart.renderer = barChartRenderer
            
            let groupSpace = 0.2
            let barSpace = 0.1 / Double(quantity)
            let barWidth = 0.7 / Double(quantity)
            // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"

            let groupCount = self.months.count
            let startYear = 0

            chartData.barWidth = barWidth
            let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
            barChart.xAxis.axisMinimum = Double(startYear)
            barChart.xAxis.axisMaximum = Double(startYear) + gg  * Double(groupCount)
            barChart.xAxis.axisRange = 10
            chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
            barChart.notifyDataSetChanged()
            barChart.data = chartData
            barChart.data?.setValueFont(UIFont(name: "Aldine721BT-Roman",
                                                    size: 12.0)!)
            
            barChart.chartDescription.enabled = false
            barChart.legend.enabled = false
            barChart.rightAxis.enabled = false
            barChart.drawValueAboveBarEnabled = true
            barChart.setVisibleXRangeMaximum(2)
            barChart.animate(yAxisDuration: 1.0, easingOption: .linear)
            barChart.doubleTapToZoomEnabled = false
            
            self.firstLegend.reloadData()
            self.secondLegend.reloadData()
            
        } else {
            self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
        }
    }
    
    // MARK: - LINECHART
    
    func getLineChart() {
        self.graphData.removeAll()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["years": arrayYear, "months": arrayMonth, "medias": arrayMedia, "providers": arrayProvider, "campaigns": arrayCampaign, "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        
        serverManager.serverCallWithHeaders(url: serverManager.inversionURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                let inversion = jsonData["inversion"]
                for i in 0..<12 {
                    let element = GraphElement(name: self.months[i], amount: 0.0)
                    self.graphData.append(element)
                }
                
                for year in inversion["years"].arrayValue {
                    for mes in year["months"].arrayValue {
                        for media in mes["media"].arrayValue {
                            for provider in media["providers"].arrayValue {
                                let index = self.graphData.firstIndex(where: { $0.name.caseInsensitiveCompare(mes["name"].string!) == .orderedSame })
                                self.graphData[Int(index!)].amount += provider["amount"].float!
                            }
                        }
                    }
                }
                
                self.graphData = self.graphData.filter{ $0.amount > 0}
                print(self.graphData)
                print(self.graphData.count)
                
                self.secondLegend.reloadData()
                let newHeight = self.secondLegend.collectionViewLayout.collectionViewContentSize.height
                self.secondLegendHeightConstraint.constant = newHeight
                self.view.setNeedsLayout()
                
                self.showLineChart()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func showLineChart() {
        if self.graphData.count > 0 {
            
            self.firstLegend.isHidden = true
            self.graphView.frame = CGRect(x: 0, y: 0, width: self.graphView.frame.size.width, height: self.graphView.frame.height + 80)
            clearGraphView()
            
            self.lineChart.frame = CGRect(x: 30, y: 0, width: self.graphView.frame.size.width - 60, height: self.graphView.frame.height - 40)

            self.graphView.addSubview(self.lineChart)
            self.graphView.bringSubviewToFront(self.buttonPresetMenu)
            // Y - Axis Setup
            let yaxis = self.lineChart.leftAxis
            yaxis.drawGridLinesEnabled = false
            yaxis.labelTextColor = UIColor.white
            yaxis.axisLineColor = UIColor.black
            yaxis.axisLineWidth = 0
            yaxis.enabled = true
            yaxis.granularityEnabled = true
            yaxis.granularity = 1
            yaxis.minWidth = 40
            yaxis.labelFont = UIFont(name: "Aldine721BT-Roman",
                                    size: 15.0)!
            //yaxis.labelXOffset = -20
            
            self.lineChart.rightAxis.enabled = false

            // X - Axis Setup
            let xaxis = self.lineChart.xAxis
            xaxis.drawGridLinesEnabled = true
            xaxis.labelTextColor = UIColor.black
            xaxis.axisLineColor = UIColor.white
            xaxis.granularityEnabled = true
            xaxis.granularity = 1
            xaxis.enabled = true
            xaxis.labelPosition = .bottom
            xaxis.labelFont = UIFont(name: "LeagueGothic-Regular",
                                     size: 20.0)!
            
            var xaxisLabelArray = [String]()
            for i in 0..<graphData.count {
                var monthTotalAmount = 0.0

                monthTotalAmount += Double(graphData[i].amount / 1000000).round(to:2)
                xaxisLabelArray.append("$ \(String(format: "%.2f", monthTotalAmount))MM \n\(self.graphData[i].name.prefix(3))")
                
            }
            xaxis.valueFormatter = IndexAxisValueFormatter(values: xaxisLabelArray)
            
            self.graphView.addSubview(self.lineChart)

            var entries = [ChartDataEntry]()
            
            var dataPoints = [String]()
            
            let monthsOrdered = arrayMonth.sorted { $0 < $1 }
            
            for x in 0..<graphData.count {
                entries.append(ChartDataEntry(x: Double(x), y: Double(self.graphData[x].amount / 1000000)))
                dataPoints.append("$ \(String(format: "%.2f", (self.graphData[x].amount / 1000000)))MM \n\(self.monthsInitials[monthsOrdered[x] - 1])")
            }
            
            let set = LineChartDataSet(values: entries, label: "1")
            set.mode = .linear
            set.setCircleColor(UIColor(rgb: 0x7F2246))
            set.circleHoleColor = UIColor(rgb: 0x7F2246)
            set.setColor(UIColor(rgb: 0x7F2246))
            set.circleRadius = 5
            set.lineWidth = 2
            set.drawValuesEnabled = false
            
            let chartData = LineChartData(dataSet: set)
            lineChart.data = chartData
            
            lineChart.pinchZoomEnabled = false
            lineChart.dragEnabled = true
            lineChart.chartDescription.enabled = false
            lineChart.legend.enabled = false
            lineChart.rightAxis.enabled = false
            lineChart.keepPositionOnRotation = true
            lineChart.clipValuesToContentEnabled = true
            lineChart.notifyDataSetChanged()
            lineChart.setVisibleXRangeMinimum(4)
            lineChart.setVisibleXRangeMaximum(4)
            lineChart.animate(yAxisDuration: 1.0, easingOption: .linear)
            lineChart.doubleTapToZoomEnabled = false
            
            self.firstLegend.reloadData()
            self.secondLegend.reloadData()
            
        } else {
            self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
        }
    }
    // MARK: - PIECHART - MEDIA
    func getPieChartMedia() {
        
        self.graphData.removeAll()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["years": arrayYear, "months": arrayMonth, "medias": arrayMedia, "providers": arrayProvider, "campaigns": arrayCampaign, "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        
        serverManager.serverCallWithHeaders(url: serverManager.inversionURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                let inversion = jsonData["inversion"]
                for year in inversion["years"].arrayValue {
                    for mes in year["months"].arrayValue {
                        for media in mes["media"].arrayValue {
                            let checkElement = self.graphData.filter { $0.name == media["name"].string!}
                            if checkElement.isEmpty {
                                var element: GraphElement = GraphElement(name: media["name"].string!, amount: 0)
                                for provider in media["providers"].arrayValue {
                                    element.amount += provider["amount"].float!
                                }
                                self.graphData.append(element)
                            } else {
                                for provider in media["providers"].arrayValue {
                                    let index = self.graphData.firstIndex(where: { $0.name == media["name"].string! })
                                    self.graphData[Int(index!)].amount += provider["amount"].float!
                                }
                            }
                        }
                    }
                }
                
                print(self.graphData)
                print(self.graphData.count)
                self.secondLegend.reloadData()
                let newHeight = self.secondLegend.collectionViewLayout.collectionViewContentSize.height
                self.secondLegendHeightConstraint.constant = newHeight
                self.view.setNeedsLayout()
                
                self.showPieChart()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    
    // MARK: - PIECHART - PROVEEDOR
    func getPieChartProvider() {
        
        self.graphData.removeAll()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["years": arrayYear, "months": arrayMonth, "medias": arrayMedia, "providers": arrayProvider, "campaigns": arrayCampaign, "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        
        serverManager.serverCallWithHeaders(url: serverManager.inversionURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                let inversion = jsonData["inversion"]
                for year in inversion["years"].arrayValue {
                    for mes in year["months"].arrayValue {
                        for media in mes["media"].arrayValue {
                            for provider in media["providers"].arrayValue {
                                let element: GraphElement = GraphElement(name: provider["name"].string!, amount: provider["amount"].float ?? 0)
                                let checkElement = self.graphData.filter { $0.name == provider["name"].string!}
                                if checkElement.isEmpty {
                                    self.graphData.append(element)
                                } else {
                                    let index = self.graphData.firstIndex(where: { $0.name == provider["name"].string! })
                                    self.graphData[Int(index!)].amount += provider["amount"].float ?? 0
                                }
                            }
                        }
                    }
                }
                print(self.graphData)
                print(self.graphData.count)
                self.secondLegend.reloadData()
                let newHeight = self.secondLegend.collectionViewLayout.collectionViewContentSize.height
                self.secondLegendHeightConstraint.constant = newHeight
                self.view.setNeedsLayout()
                
                self.showPieChart()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func showPieChart() {
        if self.graphData.count > 0 {
            
            self.firstLegend.isHidden = false
            clearGraphView()
            
            self.pieChart.frame = CGRect(x: 15, y: 0, width: self.graphView.frame.size.width - 30, height: self.graphView.frame.height)

            self.pieChart.drawEntryLabelsEnabled = false
            self.pieChart.legend.enabled = false

            self.graphView.addSubview(self.pieChart)
            self.graphView.bringSubviewToFront(self.buttonPresetMenu)
            
            var entries = [ChartDataEntry]()
            
            for x in 0..<self.graphData.count {
                self.totalAmount = self.totalAmount + self.graphData[x].amount
                entries.append(ChartDataEntry(x: Double(x + 1), y: Double(self.graphData[x].amount)))
            }
            var totalAmountString = ""
            
            if self.totalAmount < 1000 {
                totalAmountString = "$\(String(self.totalAmount))"
            } else if self.totalAmount < 1000000 {
                totalAmountString = "$\(String(format: "%.2f", self.totalAmount / 1000))K"
            } else {
                totalAmountString = "$\(String(format: "%.2f", self.totalAmount / 1000000))MM"
            }
            print("Monto total es : \(self.totalAmount)")
            
            let set = PieChartDataSet(values: entries, label: "1")
            set.colors = self.graphicColors
            set.drawValuesEnabled = false
            //set.colors = ChartColorTemplates.material()
            let data = PieChartData(dataSet: set)
            self.pieChart.data = data
            self.pieChart.holeRadiusPercent = 0.65
            self.pieChart.holeBorderColor = UIColor(rgb: 0xF2EFE9)
            self.pieChart.holeColor = UIColor(rgb: 0xF2EFE9)
            self.pieChart.highlightPerTapEnabled = false
            self.pieChart.animate(yAxisDuration: 1.0, easingOption: .linear)
            self.pieChartTopLabel.text = "SHARE MEDIOS"
            self.pieChartTopLabel.center = self.pieChart.center
            self.pieChartTopLabel.textAlignment = .center
            self.pieChartTopLabel.font = UIFont(name: "Aldine721BT-Roman",
                                     size: 17.0)
            self.pieChartTopLabel.frame = CGRect(x: self.graphView.frame.maxX / 2 - 75, y: self.pieChart.frame.maxY / 2 - 45, width: 150, height: 30)

            self.pieChartCenterLabel.text = totalAmountString
            self.pieChartCenterLabel.center = self.pieChart.center
            self.pieChartCenterLabel.textAlignment = .center
            self.pieChartCenterLabel.font = UIFont(name: "LeagueGothic-Regular",
                                     size: 50.0)
            self.pieChartCenterLabel.frame = CGRect(x: self.graphView.frame.maxX / 2 - 90, y: self.pieChart.frame.maxY / 2 - 10, width: 180, height: 50)
            
//           let monthSelected = monthList.filter({$0.id == arrayMonth[0]})
//            let startIndexMonth = monthSelected[0].name.index(monthSelected[0].name.startIndex, offsetBy: 3)
            
//            if arrayYear.count == 1 {
//                let yearSelected = yearList.filter({$0.id == arrayYear[0]})
//                self.pieChartBottomLabel.text = "\(String(monthSelected[0].name[..<startIndexMonth])) \(yearSelected[0].name)"
//            } else {
//                self.pieChartBottomLabel.text = "\(String(monthSelected[0].name[..<startIndexMonth]))"
//            }
//
//            self.pieChartBottomLabel.center = self.pieChart.center
//            self.pieChartBottomLabel.textAlignment = .center
//            self.pieChartBottomLabel.font = UIFont(name: "Aldine721BT-Roman",
//                                     size: 14.0)
//            self.pieChartBottomLabel.frame = CGRect(x: self.graphView.frame.maxX / 2 - 75, y: self.pieChart.frame.maxY / 2 + 25, width: 150, height: 30)

            self.graphView.addSubview(self.pieChartTopLabel)
            self.graphView.addSubview(self.pieChartCenterLabel)
            //self.graphView.addSubview(self.pieChartBottomLabel)
            
            self.firstLegend.reloadData()
            self.secondLegend.reloadData()
            
        } else {
            self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
        }
    }
    
    func clearGraphView() {
        self.barChart.removeFromSuperview()
        self.lineChart.removeFromSuperview()
        self.pieChart.removeFromSuperview()
        self.pieChartTopLabel.removeFromSuperview()
        self.pieChartCenterLabel.removeFromSuperview()
        self.pieChartBottomLabel.removeFromSuperview()
        //self.barChartCollectionView.removeFromSuperview()
        self.totalAmount = 0
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
            showChart()
            didSelect = false
        } else {
            if arrayYear.isEmpty {
                arrayYear = arrayBeforeFilter
            }
            if arrayMonth.isEmpty {
                arrayMonth = arrayBeforeFilter
            }
            if arrayMedia.isEmpty {
                arrayMedia = arrayBeforeFilter
            }
            if arrayProvider.isEmpty {
                arrayProvider = arrayBeforeFilter
            }
            if arrayCampaign.isEmpty {
                arrayCampaign = arrayBeforeFilter
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
        addTransparentView(searchPlaceholder: "a??o...")
    }
    @IBAction func onClickBtnMonth(_ sender: UIButton) {
        dataSource = monthList
        selectedButton = buttonMonth
        arrayBeforeFilter = arrayMonth
        arrayMonth.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "mes...")
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
    @IBAction func onClickBtnCampaign(_ sender: UIButton) {
        dataSource = campaignList
        selectedButton = buttonCampaign
        arrayBeforeFilter = arrayCampaign
        arrayCampaign.removeAll()
        didSelect = false
        tableView.reloadData()
        addTransparentView(searchPlaceholder: "campa??a...")
    }
    
    
    @IBAction func tabAdBrand(_ sender: UIButton) {
        self.performSegue(withIdentifier: "goToAdMarca", sender: self)
    }
    
    @IBAction func returnToReportList(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openPresetMenu(_ sender: UIButton) {
        
        let frames = self.view.frame
        transparentView.frame = self.view.frame
        self.view.addSubview(transparentView)
        self.view.addSubview(presetMenuTableView)
        
        self.presetMenuTableView.frame = CGRect(x: frames.midX - 100, y: frames.maxY, width: 200, height: 0)
        self.presetMenuTableView.layer.cornerRadius = 10.0
        transparentView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(removePresetMenu))
        
        presetMenuTableView.reloadData()
        
        transparentView.addGestureRecognizer(tapGesture)
        transparentView.alpha = 0
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0.5
            self.presetMenuTableView.frame = CGRect(x: frames.midX - 100, y: frames.midY - 40, width: 200, height: CGFloat(self.presetMenuOptions.count * 40))
        }, completion: nil)
    }
    
    @objc func removePresetMenu() {
        let frames = self.view.frame
        UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 1.0, options: .transitionCurlDown, animations: {
            self.transparentView.alpha = 0
            self.presetMenuTableView.frame = CGRect(x: frames.midX - 100, y: frames.maxY, width: 200, height: 0)
        }, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSavePreset" {
            let destinationVC = segue.destination as! PresetVC
            let newPreset = [arrayYear, arrayMonth, arrayMedia, arrayProvider, arrayCampaign]
            destinationVC.preset = newPreset
        } else if segue.identifier == "goToAdMarca" {
            let destinationVC = segue.destination as! AdMarcaVC
            let filter = [arrayYear, arrayMonth, arrayMedia, arrayProvider, arrayCampaign]
            destinationVC.filter = filter
        }
    }
    
}

extension InversionVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView {
            if searching {
                return dataSearch.count + 1
            } else {
                return dataSource.count + 1
            }
        } else {
            return presetMenuOptions.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
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
        } else {
            //let cell = tableView.dequeueReusableCell(withIdentifier: "InplementacionCell", for: indexPath)
            let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "PresetMenuCell")
            
            cell.textLabel?.font = UIFont(name: "LeagueGothic-Regular",
                                          size: 20.0)!
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = presetMenuOptions[indexPath.row]
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView {
            var arrayValues = [Int]()
            
            switch (selectedButton) {
                case buttonYear:
                    arrayValues = arrayYear
                case buttonMonth:
                    arrayValues = arrayMonth
                case buttonMedia:
                    arrayValues = arrayMedia
                case buttonProvider:
                    arrayValues = arrayProvider
                case buttonCampaign:
                    arrayValues = arrayCampaign
                default:
                    arrayValues = arrayYear
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
                case buttonYear:
                    arrayYear = arrayValues
                case buttonMonth:
                    arrayMonth = arrayValues
                case buttonMedia:
                    arrayMedia = arrayValues
                case buttonProvider:
                    arrayProvider = arrayValues
                case buttonCampaign:
                    arrayCampaign = arrayValues
                default:
                    arrayYear = arrayValues
            }
            
            didSelect = true
        } else {
            guard indexPath.row == 0 else {
                removePresetMenu()
                performSegue(withIdentifier: "goToSavePreset", sender: self)
                return
            }
            arrayYear.removeAll()
            arrayMonth.removeAll()
            arrayMedia.removeAll()
            arrayCampaign.removeAll()
            arrayProvider.removeAll()
            
            buttonYear.setTitle("Todos", for: .normal)
            buttonMonth.setTitle("Todos", for: .normal)
            buttonMedia.setTitle("Todos", for: .normal)
            buttonCampaign.setTitle("Todos", for: .normal)
            buttonProvider.setTitle("Todos", for: .normal)
            
            for i in 0..<yearList.count {
                arrayYear.append(yearList[i].id)
            }
            for i in 0..<monthList.count {
                arrayMonth.append(monthList[i].id)
            }
            for i in 0..<mediaList.count {
                arrayMedia.append(mediaList[i].id)
            }
            for i in 0..<campaignList.count {
                arrayCampaign.append(campaignList[i].id)
            }
            for i in 0..<providerList.count {
                arrayProvider.append(providerList[i].id)
            }
            removePresetMenu()
            showChart()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if tableView == self.tableView {
            var arrayValues = [Int]()
            switch (selectedButton) {
                case buttonYear:
                    arrayValues = arrayYear
                case buttonMonth:
                    arrayValues = arrayMonth
                case buttonMedia:
                    arrayValues = arrayMedia
                case buttonProvider:
                    arrayValues = arrayProvider
                case buttonCampaign:
                    arrayValues = arrayCampaign
                default:
                    arrayValues = arrayYear
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
                case buttonYear:
                    arrayYear = arrayValues
                case buttonMonth:
                    arrayMonth = arrayValues
                case buttonMedia:
                    arrayMedia = arrayValues
                case buttonProvider:
                    arrayProvider = arrayValues
                case buttonCampaign:
                    arrayCampaign = arrayValues
                default:
                    arrayYear = arrayValues
            }
        }
    }
}

extension InversionVC: UISearchBarDelegate {
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
            case buttonYear:
                arrayValues = arrayYear
            case buttonMonth:
                arrayValues = arrayMonth
            case buttonMedia:
                arrayValues = arrayMedia
            case buttonProvider:
                arrayValues = arrayProvider
            case buttonCampaign:
                arrayValues = arrayCampaign
            default:
                arrayValues = arrayYear
        }
        
        var arrayNames = [String]()
        for i in 0..<arrayValues.count {
            let index = dataSource.firstIndex(where: { $0.id == arrayValues[i]})
            arrayNames.append(dataSource[Int(index!)].name)
        }
        
        for section in 0..<tableView.numberOfSections {
            for row in 0..<tableView.numberOfRows(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if arrayNames.contains(tableView.cellForRow(at: indexPath)?.textLabel?.text ?? "-999" ) {
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }
            }
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        switch (selectedButton) {
            case buttonYear:
                arrayYear.removeAll()
            case buttonMonth:
                arrayMonth.removeAll()
            case buttonMedia:
                arrayMedia.removeAll()
            case buttonProvider:
                arrayProvider.removeAll()
            case buttonCampaign:
                arrayCampaign.removeAll()
            default:
                arrayYear.removeAll()
        }
    }
}

extension InversionVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == firstLegend {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FirstLegend", for: indexPath) as? FirstLegendCollectionViewCell {
                
                if numGraph == 4 || numGraph == 5 {
                    let montoTotal = graphData[indexPath.row].amount
                    var totalAmountString = ""
                    if montoTotal < 1000 {
                        totalAmountString = "$\(String(montoTotal))"
                    } else if montoTotal < 1000000 {
                        totalAmountString = "$\(String(format: "%.2f", montoTotal / 1000))K"
                    } else {
                        totalAmountString = "$\(String(format: "%.2f", montoTotal / 1000000))MM"
                    }
                    
                    cell.listarElementos(text1: totalAmountString, text2: "(\(String(format: "%.2f", (graphData[indexPath.row].amount / self.totalAmount * 100)))%)")
                    
                    let colorLine = CALayer()
                    colorLine.frame = CGRect(x: 20.0, y: cell.frame.size.height - 20, width: cell.frame.width - 40, height: 5.0)
                    colorLine.backgroundColor = graphicColors[indexPath.row].cgColor
                    cell.layer.addSublayer(colorLine)
                } else if numGraph == 1 {
                    let montoTotal = graphData[indexPath.row].amount
                    var totalAmountString = ""
                    if montoTotal < 1000 {
                        totalAmountString = "$\(String(montoTotal))"
                    } else if montoTotal < 1000000 {
                        totalAmountString = "$\(String(format: "%.2f", montoTotal / 1000))K"
                    } else {
                        totalAmountString = "$\(String(format: "%.2f", montoTotal / 1000000))MM"
                    }
                    
                    cell.listarElementos(text1: totalAmountString, text2: graphData[indexPath.row].name)
                    
                    let colorLine = CALayer()
                    colorLine.frame = CGRect(x: 20.0, y: cell.frame.size.height - 20, width: cell.frame.width - 40, height: 5.0)
                    colorLine.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    cell.layer.addSublayer(colorLine)
                    
                } else {
                    let montoTotal = graphData2[indexPath.row].amount
                    var totalAmountString = ""
                    if montoTotal < 1000 {
                        totalAmountString = "$\(String(montoTotal))"
                    } else if montoTotal < 1000000 {
                        totalAmountString = "$\(String(format: "%.2f", montoTotal / 1000))K"
                    } else {
                        totalAmountString = "$\(String(format: "%.2f", montoTotal / 1000000))MM"
                    }
                    cell.listarElementos(text1: totalAmountString, text2: graphData2[indexPath.row].timestamp)
                    let colorLine = CALayer()
                    colorLine.frame = CGRect(x: 20.0, y: cell.frame.size.height - 20, width: cell.frame.width - 40, height: 5.0)
                    colorLine.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    cell.layer.addSublayer(colorLine)
                }

                return cell
            } else {
                return UICollectionViewCell()
            }
        } else if collectionView == secondLegend {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondLegend", for: indexPath) as? SecondLegendCollectionViewCell {
                
                if numGraph == 1 {
                    let nameLeft: [FilterBody] = self.providerList.filter(){$0.id == self.arrayProvider[0]}
                    
                    cell.listarEle(color: graphicColors[0], nombre: nameLeft[0].name)
                } else {
                    cell.listarEle(color: graphicColors[indexPath.row], nombre: graphData[indexPath.row].name)
                }
                
            
                return cell
            } else {
                return UICollectionViewCell()
            }
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == firstLegend {
            if numGraph == 1 || numGraph == 4 || numGraph == 5 {
                return graphData.count
            } else {
                return graphData2.count
            }
        } else {
            if numGraph == 1 {
                return 1
            } else {
                return graphData.count
            }
        }
    }
    

}

extension InversionVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == firstLegend {
            if graphData.count < 5 {
                let totalCellWidth = 80 * collectionView.numberOfItems(inSection: 0)
                let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)

                let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
                let rightInset = leftInset

                return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
            } else {
                return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            }
        } else {
            if graphData.count < 5 {
                let totalCellWidth = 100 * collectionView.numberOfItems(inSection: 0)
                let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)

                let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
                let rightInset = leftInset

                return UIEdgeInsets(top: 5, left: leftInset, bottom: 0, right: rightInset)
            } else {
                return UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 0)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == secondLegend {
            let label = UILabel(frame: CGRect.zero)
            if numGraph == 1 {
                print(self.arrayProvider)
                let nameLeft: [FilterBody] = providerList.filter(){$0.id == self.arrayProvider[0]}
                label.text = nameLeft[0].name
            } else {
                label.text = graphData[indexPath.row].name
            }
            label.sizeToFit()
            //return CGSize(width: label.frame.width + 25, height: 20)
            return CGSize(width: 100, height: 20)
        } else if collectionView == firstLegend {
            return CGSize(width: 80, height: 70)
        } else {
            return CGSize(width: 100, height: 300)
        }
        
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
