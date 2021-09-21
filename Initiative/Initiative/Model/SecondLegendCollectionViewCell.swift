//
//  SecondLegendCollectionViewCell.swift
//  Initiative
//
//  Created by Andres Liu on 11/5/20.
//

import UIKit

class SecondLegendCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var circle: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    public func listarEle(color: UIColor, nombre: String){
        circle.tintColor = color
        name.text = nombre
    }
}
