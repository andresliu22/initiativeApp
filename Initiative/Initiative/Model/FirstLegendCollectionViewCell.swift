//
//  FirstLegendCollectionViewCell.swift
//  Initiative
//
//  Created by Andres Liu on 11/5/20.
//

import UIKit

class FirstLegendCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var percentage: UILabel!

    public func listarElementos(text1: String, text2: String){
        amount.text = text1
        percentage.text = text2
    }
    
}
