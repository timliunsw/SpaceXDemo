//
//  UIViewController+Extension.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/11/21.
//

import UIKit

extension UIViewController {
    func showAlert( _ message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
