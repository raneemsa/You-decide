//
//  ViewController+Extensions.swift
//  Virtual Tourist
//
//  Created by Raneem on 5/17/19.
//  Copyright © 2019 Raneem. All rights reserved.
//

import UIKit

extension UIViewController {
    
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func performUpdates(_ updates: @escaping () -> Void) {
        DispatchQueue.main.async {
            updates()
        } }
    
    
    func save() {
        do {
            try CoreDataStack.shared().saveContext()
        } catch {
            showInfo(withTitle: "Error", withMessage: "Error while saving: \(error)")
        }
    }
    
    
    func showInfo(withTitle: String = "Info", withMessage: String, action: (() -> Void)? = nil) {
        performUpdates {
            let ac = UIAlertController(title: withTitle, message: withMessage, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) in
                action?()
            }))
            self.present(ac, animated: true)
        }
    }
    
}


