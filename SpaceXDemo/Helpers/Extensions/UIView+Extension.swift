//
//  UIView+Extension.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import UIKit

extension UIView {
    
    /**
     Activate top, left, bottom and right constaints to superview.
     
     - parameter top: top constraint to superview. It is `0` by default.
     - parameter left: left constraint to superview. It is `0` by default.
     - parameter bottom: bottom constraint to superview. It is `0` by default.
     - parameter right: right constraint to superview. It is `0` by default.
     */
    func constraintsToSuperview(withInsetsTop top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) {
        guard let superview = superview else {
            return
        }
        
        let constraints: [NSLayoutConstraint] = [
            topAnchor.constraint(equalTo: superview.topAnchor, constant: top),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -bottom),
            leftAnchor.constraint(equalTo: superview.leftAnchor, constant: left),
            rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -right),
        ]
        NSLayoutConstraint.activate(constraints)
    }
}

