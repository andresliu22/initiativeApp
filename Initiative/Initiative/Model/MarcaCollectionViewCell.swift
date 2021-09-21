//
//  CollectionViewCell.swift
//  Initiative
//
//  Created by Andres Liu on 10/14/20.
//

import UIKit

class MarcaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var marcaName: UILabel!
    @IBOutlet weak var nextArrow: UIImageView!
    
    static let identifier = "Marca"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    public func configure(name: String, selected: Bool){
        marcaName.text = name
        marcaName.sizeToFit()
        
        if selected {
            marcaName.textColor = UIColor(rgb: 0x59C7ED)
            nextArrow.tintColor = UIColor(rgb: 0x59C7ED)
        } else {
            marcaName.textColor = UIColor.white
            nextArrow.tintColor = UIColor.white
        }
    }
    
}

