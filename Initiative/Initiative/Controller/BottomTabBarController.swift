//
//  BottomTabBarController.swift
//  Initiative
//
//  Created by Andres Liu on 10/25/20.
//

import UIKit

class BottomTabBarController: UITabBarController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = #colorLiteral(red: 0.9596082568, green: 0.9495453238, blue: 0.9308989048, alpha: 1)
        appearance.inlineLayoutAppearance.normal.iconColor = UIColor.black
        //tabBar.standardAppearance = appearance
        tabBar.isTranslucent = true
    }


}
