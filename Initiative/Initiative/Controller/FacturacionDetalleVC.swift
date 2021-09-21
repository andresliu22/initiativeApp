//
//  FacturacionDetalleVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/30/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import Charts

class FacturacionDetalleVC: UIViewController {

    @IBOutlet weak var tabBalance: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabBalance.frame.size.height - 2, width: tabBalance.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            tabBalance.layer.addSublayer(bottomBorder)
        }
    }
    @IBOutlet weak var tabDetalle: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabDetalle.frame.size.height - 2, width: tabDetalle.frame.width, height: 2.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tabDetalle.layer.addSublayer(bottomBorder)
        }
    }
    @IBOutlet weak var buttonYear: UIButton!
    @IBOutlet weak var legendCV: UICollectionView!
    @IBOutlet weak var graphView: UIView! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: 0, width: graphView.frame.width, height: 1.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            graphView.layer.addSublayer(bottomBorder)
        }
    }
    
    
    @IBOutlet weak var categoryView: UIView!
    
    @IBOutlet weak var detailCV: UICollectionView!
    
    @IBOutlet weak var detailContentView: UIView! {
        didSet {            
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: detailContentView.frame.size.height, width: detailContentView.frame.width, height: 1.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            detailContentView.layer.addSublayer(bottomBorder)
        }
    }
    var arrayYear = [Int]()

    var yearList = [FilterBody]()
    
    var arrayBeforeFilter = [Int]()
    
    let transparentView = UIView()
    let borderView = UIView()
    let inBetweenView = UIView()
    let searchBar = UISearchBar()
    let tableView = UITableView()
    var selectedButton = UIButton()
    var lineChart = LineChartView()
    
    var dataSource = [FilterBody]()
    var dataSearch = [FilterBody]()
    var searching = false
    var didSelect = false
    var idCurrency = 2
    
    var graphData = [FacturacionDetalleStruct]()
    var graphicColors: [UIColor] = [UIColor(rgb: 0x7F2246), UIColor(rgb: 0xD93251), UIColor(rgb: 0x3F7F91), UIColor(rgb: 0x2C274C), UIColor(rgb: 0x3F7791), UIColor(rgb: 0x42173E), UIColor(rgb: 0xA3294A), UIColor(rgb: 0x37547F)]
    let months = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"]
    
    let monthsInitials = ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Set", "Oct", "Nov", "Dic"]
    let legendValues = ["Consumido", "Pagado"]
    
    var detailData = [FacturacionDetalleTabla]()
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonYear.addBorders(width: 1)
        buttonYear.titleEdgeInsets.left = 10
        buttonYear.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        
        let rightBorder = CALayer()
        rightBorder.frame = CGRect(x: self.view.frame.width * 0.25, y: 0, width: 1, height: categoryView.frame.height)
        rightBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        categoryView.layer.addSublayer(rightBorder)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(CellClass.self, forCellReuseIdentifier: "ImplementacionCell")

        self.searchBar.delegate = self
        self.legendCV.dataSource = self
        self.legendCV.delegate = self
        
        self.detailCV.dataSource = self
        self.detailCV.delegate = self
        
        self.tableView.reloadData()
        getFilters()
    }

    func getFilters() {
        yearList = NetworkManager.shared.getYears()
        
        arrayYear.append(yearList[yearList.count - 1].id)
        buttonYear.setTitle(yearList[yearList.count - 1].name, for: .normal)
        getLineChart()
    }
    
    func getLineChart() {
        self.graphData.removeAll()
        self.detailData.removeAll()
        let serverManager = ServerManager()
        let parameters : Parameters  = ["year": arrayYear[0], "idCurrency": UserDefaults.standard.integer(forKey: "moneda"), "idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        
        serverManager.serverCallWithHeaders(url: serverManager.facturacionURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                
                for i in 0..<12 {
                    let element = FacturacionDetalleStruct(name: self.months[i], consumido: 0.0, pagado: 0.0)
                    self.graphData.append(element)
                    let newDetail = FacturacionDetalleTabla(mes: self.months[i], consumido: 0.0, facturado: 0.0, porFacturar: 0.0, pagado: 0.0, porPagar: 0.0, vencido: 0.0)
                    self.detailData.append(newDetail)
                }
                
                for month in jsonData["billings"].arrayValue {
            
                    let index = self.graphData.firstIndex(where: { $0.name.caseInsensitiveCompare(month["month"].string!) == .orderedSame })
                    self.graphData[Int(index!)].consumido += month["amountConsumed"].float!
                    self.graphData[Int(index!)].pagado += month["amountPaid"].float!
                    
                    let detailIndex = self.detailData.firstIndex(where: { $0.mes.caseInsensitiveCompare(month["month"].string!) == .orderedSame })
                    
                    self.detailData[Int(detailIndex!)].consumido += month["amountConsumed"].float ?? 0
                    self.detailData[Int(detailIndex!)].facturado += month["amountInvoice"].float ?? 0
                    self.detailData[Int(detailIndex!)].porFacturar += month["amountToBilled"].float ?? 0
                    self.detailData[Int(detailIndex!)].pagado += month["amountPaid"].float ?? 0
                    self.detailData[Int(detailIndex!)].porPagar += month["amountToPayToBeat"].float ?? 0
                    self.detailData[Int(detailIndex!)].vencido += month["amountToPayDefeated"].float ?? 0

                }
                
                //self.graphData = self.graphData.filter{ $0.consumido > 0}
                print(self.graphData)
                print(self.graphData.count)
                self.showLineChart(dataPoints: self.monthsInitials)
                self.detailCV.reloadData()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func showLineChart(dataPoints: [String]) {
        if self.graphData.count > 0 {
            clearGraphView()

            self.lineChart.frame = CGRect(x: 20, y: 0, width: self.graphView.frame.size.width - 30, height: self.graphView.frame.height - 10)

            // Y - Axis Setup
            let yaxis = self.lineChart.leftAxis
            yaxis.drawGridLinesEnabled = false
            yaxis.labelTextColor = UIColor.black
            yaxis.axisLineColor = UIColor.black
            yaxis.enabled = true
            yaxis.labelAlignment = .left
            yaxis.labelCount = 4
            //yaxis.xOffset = 20
            //yaxis.minWidth = 0
            //yaxis.labelXOffset = -50
            //yaxis.minWidth = 30
            yaxis.axisLineWidth = 0.0
            yaxis.axisLineColor = UIColor.black
            //yaxis.centerAxisLabelsEnabled = true
            yaxis.labelFont = UIFont(name: "Aldine721BT-Roman",
                                    size: 10.0)!
            yaxis.valueFormatter = YAxisLineChartFormatter()
            self.lineChart.rightAxis.enabled = false
            
            let rightBorder = CALayer()
            rightBorder.frame = CGRect(x: self.view.frame.width * 0.25, y: 0, width: 1, height: graphView.frame.height)
            rightBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            graphView.layer.addSublayer(rightBorder)
            
            // X - Axis Setup
            let xaxis = self.lineChart.xAxis
            xaxis.drawGridLinesEnabled = false
            xaxis.labelTextColor = UIColor.black
            xaxis.axisLineColor = UIColor.white
            xaxis.granularityEnabled = true
            xaxis.enabled = true
            xaxis.labelPosition = .bottom
            xaxis.labelFont = UIFont(name: "Aldine721BT-Roman",
                                     size: 12.0)!
            xaxis.drawGridLinesEnabled = false
            xaxis.valueFormatter = IndexAxisValueFormatter(values: self.monthsInitials)
            
            self.graphView.addSubview(self.lineChart)

            var entries = [ChartDataEntry]()
            var entries2 = [ChartDataEntry]()
            
            for x in 0..<graphData.count {
                entries.append(ChartDataEntry(x: Double(x), y: Double(graphData[x].consumido / 1000000).round(to: 2)))
                entries2.append(ChartDataEntry(x: Double(x), y: Double(graphData[x].pagado / 1000000).round(to: 2)))
            }
            
            let set = LineChartDataSet(values: entries, label: "Consumido")
            let set2 = LineChartDataSet(values: entries2, label: "Pagado")
            
            set.mode = .linear
            set.setCircleColor(UIColor(rgb: 0x7F2246))
            set.circleHoleColor = UIColor(rgb: 0x7F2246)
            set.setColor(UIColor(rgb: 0x7F2246))
            set.circleRadius = 4
            set.lineWidth = 2
            set.drawValuesEnabled = false
            
            set2.mode = .linear
            set2.setCircleColor(UIColor(rgb: 0xD93251))
            set2.circleHoleColor = UIColor(rgb: 0xD93251)
            set2.setColor(UIColor(rgb: 0xD93251))
            set2.circleRadius = 4
            set2.lineWidth = 2
            set2.drawValuesEnabled = false
            
            var datasets = [LineChartDataSet]()
            datasets.append(set)
            datasets.append(set2)
            
            let chartData = LineChartData(dataSets: datasets)
            
            let pFormatter = NumberFormatter()
            pFormatter.numberStyle = .currency
            pFormatter.maximumFractionDigits = 2
            pFormatter.multiplier = 1.0
            //pFormatter.zeroSymbol = ""
            pFormatter.currencySymbol = "$"
            pFormatter.positiveSuffix = "MM"
            chartData.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
            chartData.setDrawValues(true)
            chartData.setValueTextColor(UIColor.black)
            
            lineChart.data = chartData
            
            lineChart.chartDescription.enabled = false
            lineChart.legend.enabled = false
            lineChart.rightAxis.enabled = false
            lineChart.notifyDataSetChanged()
            lineChart.setVisibleXRangeMaximum(3)
            lineChart.animate(yAxisDuration: 1.0, easingOption: .linear)
            lineChart.doubleTapToZoomEnabled = false

        } else {
            self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
        }
    }
    
    func clearGraphView() {
        self.lineChart.removeFromSuperview()
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
            getLineChart()
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
    
    @IBAction func goToBalance(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func returnToListado(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension FacturacionDetalleVC: UITableViewDataSource {
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

extension FacturacionDetalleVC: UITableViewDelegate {
    
}

extension FacturacionDetalleVC: UISearchBarDelegate {
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

extension FacturacionDetalleVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == legendCV {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SecondLegend", for: indexPath) as? SecondLegendCollectionViewCell {
                
                cell.listarEle(color: graphicColors[indexPath.row], nombre: legendValues[indexPath.row])

                return cell
            } else {
                return UICollectionViewCell()
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "facturacionDetalleCell", for: indexPath) as? FacturacionDetalleCVC {
                
                cell.listarDetalle(mesNombre: String(detailData[indexPath.row].mes.prefix(3)), consumido: detailData[indexPath.row].consumido, facturado: detailData[indexPath.row].facturado, porFacturar: detailData[indexPath.row].porFacturar, pagado: detailData[indexPath.row].pagado, porPagar: detailData[indexPath.row].porPagar, vencido: detailData[indexPath.row].vencido)

                return cell
            } else {
                return UICollectionViewCell()
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == legendCV {
            return 2
        } else {
            return detailData.count
        }
        
    }
    

}

extension FacturacionDetalleVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if collectionView == legendCV {
            let totalCellWidth = 120 * collectionView.numberOfItems(inSection: 0)
            let totalSpacingWidth = 10 * (collectionView.numberOfItems(inSection: 0) - 1)

            let leftInset = (collectionView.layer.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
            let rightInset = leftInset

            return UIEdgeInsets(top: 10, left: leftInset, bottom: 0, right: rightInset)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == legendCV {
            let label = UILabel(frame: CGRect.zero)
            label.text = legendValues[indexPath.row]
            label.sizeToFit()
            return CGSize(width: label.frame.width + 40, height: 32)
        } else {
            return CGSize(width: 80, height: 210)
        }
    }
}
