//
//  ReporteCollectionViewCell.swift
//  Initiative
//
//  Created by Andres Liu on 10/22/20.
//

import UIKit

class ReporteCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var imagen: UIImageView!
    @IBOutlet weak var descripcion: UILabel!
    
    public func listarReporte(title: String, logo: UIImage, fecha: String){
        titulo.text = title
        imagen.image = logo
        descripcion.text = fecha
    }
}
