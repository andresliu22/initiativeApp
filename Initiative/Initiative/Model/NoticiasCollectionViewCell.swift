//
//  NoticiasCollectionViewCell.swift
//  Initiative
//
//  Created by Andres Liu on 10/25/20.
//

import UIKit

class NoticiasCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imgUrl: UIImageView!
    @IBOutlet weak var noticiaTitulo: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    public func listarNoticia(imagenURL: String, titulo: String, fecha: String) {
        if let url = NSURL(string: imagenURL) {
            if let data = NSData(contentsOf: url as URL) {
                imgUrl.image = UIImage(data: data as Data)!.resizeImage(targetSize: CGSize(width: 360, height: 160))
            }
        }
        noticiaTitulo.text = titulo
        timestamp.text = fecha
        
    }
}
