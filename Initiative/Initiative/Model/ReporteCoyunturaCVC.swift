//
//  ReporteCoyunturaCVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/27/20.
//

import UIKit

class ReporteCoyunturaCVC: UICollectionViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var imageUrl: UIImageView!
    @IBOutlet weak var year: UILabel!
    
    public func listarReporteCoyuntura(titulo: String, imagenURL: String, fecha: String) {
        if let url = NSURL(string: imagenURL) {
            if let data = NSData(contentsOf: url as URL) {
                imageUrl.image = UIImage(data: data as Data)
            }
        }
        title.text = titulo
        year.text = fecha
        
    }
}
