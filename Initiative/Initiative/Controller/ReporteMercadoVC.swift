//
//  ReporteMercadoVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/26/20.
//

import UIKit
import Alamofire
import SwiftyJSON
import PDFKit
import WebKit

class ReporteMercadoVC: UIViewController, UIDocumentInteractionControllerDelegate {

    
    @IBOutlet weak var reporteSemestralCV: UICollectionView!
    @IBOutlet weak var reporteCoyunturaCV: UICollectionView!
    
    var arraySemestral = [ReporteMercado]()
    var arrayCoyuntura = [ReporteMercado]()
    
    var reporteSeleccionado = 1
    
    let webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reporteSemestralCV.dataSource = self
        reporteSemestralCV.delegate = self
        
        reporteCoyunturaCV.dataSource = self
        reporteCoyunturaCV.delegate = self
        
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
                print(jsonData)
                for reporte in jsonData["marketReports"].arrayValue {
                    var newPdf = reporte["pdfUrl"].string!.replacingOccurrences(of:#"\"#, with: "")
                    newPdf = newPdf.replacingOccurrences(of:" ", with: "%20")
                    let newImg = reporte["imageUrl"].string!.replacingOccurrences(of:#"\"#, with: "")
            
                    let reportElement = ReporteMercado(title: reporte["title"].string!, subtitle: reporte["subtitle"].string!, imageUrl: newImg, reportType: reporte["reportType"].string!, pdfUrl: newPdf)
                    
                    if reporte["reportType"].string! == "SEMESTRALES" {
                        self.arraySemestral.append(reportElement)
                    } else if reporte["reportType"].string! == "COYUNTURA" {
                        self.arrayCoyuntura.append(reportElement)
                    }
                    
                }
                self.reporteSemestralCV.reloadData()
                self.reporteCoyunturaCV.reloadData()
            } else {
                self.showAlert(title: "Error", message: "Datos no fueron cargados correctamente")
            }
        })
    }
    
//    func showPDF(urlPath: String) {
//        let docController = UIDocumentInteractionController.init(url: URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(urlPath))
//        docController.delegate = self
//        docController.presentPreview(animated: true)
//    }
//
//    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
//        return self
//    }
    
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
    
    
//    private func createPdfView(withFrame frame: CGRect) -> PDFView {
//        let pdfView = PDFView(frame: frame)
//        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        pdfView.autoScales = true
//
//        return pdfView
//    }
//
//    private func createPdfDocument(forFileName fileName: String, urlPath: String) -> PDFDocument? {
//        if let resourceUrl = URL(string: urlPath) {
//            return PDFDocument(url: resourceUrl)
//        }
//
//        return nil
//    }
//
//    private func displayPdf(urlPath: String) {
//        let pdfView = self.createPdfView(withFrame: self.view.bounds)
//
//        if let pdfDocument = self.createPdfDocument(forFileName: "Visualizer", urlPath: urlPath) {
//            self.view.addSubview(pdfView)
//            pdfView.document = pdfDocument
//        }
//    }
    
    @IBAction func goToReporteSemestral(_ sender: UIButton) {
        print("goToReporteSemestral")
        reporteSeleccionado = 1
        performSegue(withIdentifier: "goToReporteMercado2", sender: self)
    }
    @IBAction func goToReporteCoyuntura(_ sender: UIButton) {
        print("goToReporteCoyuntura")
        reporteSeleccionado = 2
        performSegue(withIdentifier: "goToReporteMercado2", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToReporteMercado2" {
            let destinationVC = segue.destination as! ListadoReporteMercadoVC
            destinationVC.tipoReporte = reporteSeleccionado
        }
    }
    
    @IBAction func returnToListado(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ReporteMercadoVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == reporteSemestralCV {
            return arraySemestral.count
        } else {
            return arrayCoyuntura.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == reporteSemestralCV {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "semestral", for: indexPath) as? ReporteSemestralCVC {
                cell.listarReporteSemestral(titulo: arraySemestral[indexPath.row].title, imagenURL: arraySemestral[indexPath.row].imageUrl, fecha: arraySemestral[indexPath.row].subtitle)
                
                cell.layer.backgroundColor = UIColor(rgb: 0x3C7F92).cgColor
                return cell
            } else {
                return UICollectionViewCell()
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "coyuntura", for: indexPath) as? ReporteCoyunturaCVC {
                cell.listarReporteCoyuntura(titulo: arrayCoyuntura[indexPath.row].title, imagenURL: arrayCoyuntura[indexPath.row].imageUrl, fecha: arrayCoyuntura[indexPath.row].subtitle)
                
                cell.layer.backgroundColor = UIColor(rgb: 0x365381).cgColor
                return cell
            } else {
                return UICollectionViewCell()
            }
        }
    }
    
    
}

extension ReporteMercadoVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == reporteSemestralCV {
            displayWebView(urlPath: arraySemestral[indexPath.row].pdfUrl)
//            displayPdf(urlPath: arraySemestral[indexPath.row].pdfUrl)
//            if let url = URL(string: arraySemestral[indexPath.row].pdfUrl) {
//                UIApplication.shared.open(url)
//            }
        } else {
            displayWebView(urlPath: arrayCoyuntura[indexPath.row].pdfUrl)
//            if let url = URL(string: arrayCoyuntura[indexPath.row].pdfUrl) {
//                UIApplication.shared.open(url)
//            }
        }
        
    }
}

extension ReporteMercadoVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = ((self.view.frame.height - 40) / 2) * 0.85 - 40
        let cellWidth = cellHeight / 3 * 2
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

