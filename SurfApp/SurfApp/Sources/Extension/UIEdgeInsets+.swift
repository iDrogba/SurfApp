//
//  UIEdgeInsets.swift
//  SurfApp
//
//  Created by 김상현 on 2023/04/10.
//

import UIKit

extension UIEdgeInsets {
    
    static var defaultInsets: UIEdgeInsets {
        let defaultHorizontalPadding = UIScreen.main.bounds.width * 0.03
        let defaultVerticalPadding = UIScreen.main.bounds.width * 0.05
        
        return UIEdgeInsets(top: defaultVerticalPadding, left: defaultHorizontalPadding, bottom: defaultVerticalPadding, right: defaultHorizontalPadding)
    }

}
