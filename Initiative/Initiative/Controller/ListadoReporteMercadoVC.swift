//
//  ListadoReporteMercadoVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/30/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class ListadoReporteMercadoVC: UIViewController {

    @IBOutlet weak var reporteTableView: UITableView!
    var tipoReporte = 1
    var arrayReportes = [ReporteMercado]()
    let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reporteTableView.dataSource = self
        reporteTableView.delegate = self
        reporteTableView.backgroundColor = UIColor(rgb: 0xF2EFE9)
        
        getReportes()
    }

    func getReportes() {
        let serverManager = ServerManager()
        let parameters : Parameters  = ["idBrand": UserDefaults.standard.string(forKey: "idBrand")!]
        
        serverManager.serverCallWithHeaders(url: serverManager.reporteMercadoURL, params: parameters, method: .post, callback: {  (intCheck : Int, jsonData : JSON) -> Void in
            if intCheck == 1 {
                guard !jsonData.isEmpty else {
                    self.showAlert(title: "Error", message: "No hay datos con determinado filtro")
                    return
                }
                for reporte in jsonData["marketReports"].arrayValue {
                    var newPdf = reporte["pdfUrl"].string!.replacingOccurrences(of:#"\"#, with: "")
                    newPdf = newPdf.replacingOccurrences(of:" ", with: "%20")
                    let newImg = reporte["imageUrl"].string!.replacingOccurrences(of:#"\"#, with: "")
                    let reportElement = ReporteMercado(title: reporte["title"].string!, subtitle: reporte["subtitle"].string!, imageUrl: newImg, reportType: reporte["reportType"].string!, pdfUrl: newPdf)
                    
                    if self.tipoReporte == 1 {
                        if reporte["reportType"].string! == "SEMESTRALES" {
                            self.arrayReportes.append(reportElement)
                        }
                    } else if self.tipoReporte == 2 {
                        if reporte["reportType"].string! == "COYUNTURA" {
                           self.arrayReportes.append(reportElement)
                       }
                    }
                }
                self.reporteTableView.reloadData()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
    func createWebView(withFrame frame: CGRect, urlPath: String) -> WKWebView? {
        
        webView.frame = frame
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        if let resourceUrl = URL(string: urlPath) {
            let request = URLRequest(url: resourceUrl)
            webView.load(request)
            
            return webView
        }
        
        return nil
    }
    
    func displayWebView(urlPath: String) {
        if let webView = self.createWebView(withFrame: self.view.bounds, urlPath: urlPath) {
            self.view.addSubview(webView)
            let doneButton = UIButton()
            doneButton.frame = CGRect(x: webView.frame.maxX - 100, y: 30, width: 80, height: 30)
            doneButton.setTitle("Cerrar", for: .normal)
            doneButton.backgroundColor = UIColor(rgb: 0x4BBAE8)
            doneButton.setTitleColor(UIColor.black, for: .normal)
            doneButton.titleLabel?.font = UIFont(name: "Aldine721BT-Roman",
                                                 size: 12.0)!
            //doneButton.addBorders(width: 1)
            doneButton.layer.cornerRadius = 10
            doneButton.addTarget(self, action: #selector(closePDF), for: .touchUpInside)
            webView.addSubview(doneButton)
        }
    }
    
    @objc func closePDF() {
        webView.removeFromSuperview()
    }
    
    @IBAction func returnToReporteMercado(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ListadoReporteMercadoVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayReportes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "ListadoReporteMercadoCell")
        
        
        cell.backgroundColor = UIColor(rgb: 0xF2EFE9)
        cell.textLabel?.font = UIFont(name: "Aldine721BT-Roman",
                                      size: 15.0)
        
        cell.textLabel?.text = "\(arrayReportes[indexPath.row].title) - \(arrayReportes[indexPath.row].subtitle)"
        
        cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right")!.withTintColor(.black, renderingMode: .alwaysOriginal))

        return cell
    }
    
    
}

extension ListadoReporteMercadoVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayWebView(urlPath: arrayReportes[indexPath.row].pdfUrl)
//        if let url = URL(string: arrayReportes[indexPath.row].pdfUrl) {
//            UIApplication.shared.open(url)
//        }
    }
}
