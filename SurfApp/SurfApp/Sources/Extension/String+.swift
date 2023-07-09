//
//  String+.swift
//  SurfApp
//
//  Created by 김상현 on 2023/07/09.
//

import Foundation

extension String {

     var localized: String {

           return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")

        }
}
