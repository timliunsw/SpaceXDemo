//
//  String+Extension.swift
//  SpaceXDemo
//
//  Created by Tim Li on 15/9/21.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
