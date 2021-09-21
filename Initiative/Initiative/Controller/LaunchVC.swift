//
//  LaunchVC.swift
//  Initiative
//
//  Created by Andres Liu on 12/15/20.
//

import UIKit

class LaunchVC: UIViewController {

    @IBOutlet weak var launchView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.bool(forKey: "isUserLoggedIn") == true {
            navigateToLogin(animation: false)
            //self.performSegue(withIdentifier: "goToMarcas", sender: self)
        }
    }
    
    func navigateToLogin(animation: Bool) {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        self.navigationController?.pushViewController(loginVC, animated: animation)
    }
    
    @IBAction func handlePan(_ gesture: UIPanGestureRecognizer) {
        
      let translation = gesture.translation(in: view)
        
      if translation.y < -15 {
        performSegue(withIdentifier: "goToLogin", sender: self)
      }
        
      gesture.setTranslation(.zero, in: view)
    }

}
