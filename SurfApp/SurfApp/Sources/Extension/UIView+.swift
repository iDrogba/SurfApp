//
//  UIView+.swift
//  SurfApp
//
//  Created by 김상현 on 2023/04/10.
//

import UIKit

extension UIView {
    func setCornerRadiusShadow(cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        
        self.layer.shadowOpacity = 0.3
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowRadius = 10

        self.layer.masksToBounds = false
    }
}
