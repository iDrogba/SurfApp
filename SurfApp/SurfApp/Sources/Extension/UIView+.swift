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
        
        self.layer.shadowOpacity = 0.2
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize.zero
        self.layer.shadowRadius = 10

        self.layer.masksToBounds = false
    }
    
    func setGradient(gradientColor: (UIColor, UIColor)){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.colors = [gradientColor.0.cgColor, gradientColor.1.cgColor]
        gradient.locations = [0.0 , 1.0]
        gradient.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = bounds
        layer.addSublayer(gradient)
    }
    
}
