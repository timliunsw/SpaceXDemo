//
//  UIView+Extension.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import UIKit

extension UIView {
    func constraintsToSuperview(withInsetsTop top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        guard let sview = superview else {
            return
        }
        
        let constraints: [NSLayoutConstraint] = [
            topAnchor.constraint(equalTo: sview.topAnchor, constant: top),
            bottomAnchor.constraint(equalTo: sview.bottomAnchor, constant: -bottom),
            leftAnchor.constraint(equalTo: sview.leftAnchor, constant: left),
            rightAnchor.constraint(equalTo: sview.rightAnchor, constant: -right),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

