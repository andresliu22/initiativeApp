//
//  NotificacionVC.swift
//  Initiative
//
//  Created by Andres Liu on 12/7/20.
//

import UIKit

class NotificacionVC: UIViewController {

    
    @IBOutlet weak var tabChangePass: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabChangePass.frame.size.height - 3, width: tabChangePass.frame.width, height: 3.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            tabChangePass.layer.addSublayer(bottomBorder)
        }
    }
    
    @IBOutlet weak var tabNotifications: UIButton! {
        didSet {
            let bottomBorder = CALayer()
            bottomBorder.frame = CGRect(x: 0.0, y: tabNotifications.frame.size.height - 3, width: tabNotifications.frame.width, height: 3.0)
            bottomBorder.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            tabNotifications.layer.addSublayer(bottomBorder)
        }
    }
    
    @IBOutlet weak var buttonActivar: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonActivar.addBorders(width: 1)
    }
    
    @IBAction func goToChangePass(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func returnToListado(_ sender: UIButton) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func activeNotifications(_ sender: UIButton) {
    }
}
