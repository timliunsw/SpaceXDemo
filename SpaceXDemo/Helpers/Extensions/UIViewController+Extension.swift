//
//  UIViewController+Extension.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/11/21.
//

import UIKit

extension UIViewController {
    /**
     Show an alert with message and OK action.
     
     - parameter message: Alert message.
     - parameter completion: A block that's called after OK action  is finished. This parameter may be `NULL`.
     */
    func showAlert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Alert".localized,
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized, style: .default) { action in
            completion?()
        }
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
