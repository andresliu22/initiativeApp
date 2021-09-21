//
//  GuiaMarcaVC.swift
//  Initiative
//
//  Created by Andres Liu on 10/16/20.
//

import UIKit

class GuiaMarcaVC: UIViewController {
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))

    }

}

// MARK: Drag dismiss function
extension GuiaMarcaVC {
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
            switch sender.state {
            case .changed:
                viewTranslation = sender.translation(in: view)
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                })
                
            case .ended:
                if viewTranslation.y < 200 {
                    UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                        self.view.transform = .identity
                    })
                } else {
                    dismiss(animated: true, completion: nil)
                }
            default:
                break
            }
        }
}

