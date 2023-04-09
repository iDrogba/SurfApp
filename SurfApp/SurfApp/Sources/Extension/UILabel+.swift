//
//  UILabel+.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/22.
//

import UIKit

extension UILabel {
    
    static func makeLabel(text: String? = nil, fontColor: UIColor, font: UIFont, textAlignment: NSTextAlignment? = nil) -> UILabel {
        let label = UILabel()
        
        label.textColor = fontColor
        label.font = font
        
        if let text {
            label.text = text
        }
        
        if let textAlignment {
            label.textAlignment = textAlignment
        }
        
        return label
    }
    
}
