//
//  UIStackView+.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/22.
//

import UIKit

extension UIStackView {
    
    static func makeDefaultStackView(axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment, distribution: UIStackView.Distribution, spacing: CGFloat = 0, layoutMargin: UIEdgeInsets? = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), color: UIColor? = .clear, cornerRadius: CGFloat = 0) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.alignment = alignment
        stackView.distribution = distribution
        stackView.spacing = spacing
        
        stackView.backgroundColor = color
        stackView.layer.cornerRadius = cornerRadius
        
        if let layoutMargin {
            stackView.isLayoutMarginsRelativeArrangement = true
            stackView.layoutMargins = layoutMargin
        }
        
        return stackView
    }
    
}
