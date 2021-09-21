//
//  TermYCondVC.swift
//  Initiative
//
//  Created by Andres Liu on 11/23/20.
//

import UIKit

class TermYCondVC: UIViewController {

    @IBOutlet weak var tycLabel: UILabel!
    var tycText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tycLabel.text = tycText
    }
    
    @IBAction func returnToListado(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}
