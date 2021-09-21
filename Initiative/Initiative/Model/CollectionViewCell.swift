//
//  CollectionViewCell.swift
//  Initiative
//
//  Created by Andres Liu on 10/14/20.
//

import UIKit

class MarcaCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var holaImage: UIImageView!
    @IBOutlet var marcaName: UILabel!
    
    static let identifier = "Marca"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    public func configure(logo: UIImage, name: String){
        holaImage.layer.borderWidth = 1
        holaImage.layer.masksToBounds = false
        holaImage.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        holaImage.layer.cornerRadius = holaImage.frame.height/2
        holaImage.clipsToBounds = true
        holaImage.image = logo
        marcaName.text = name
        marcaName.sizeToFit()
    }
    
}

