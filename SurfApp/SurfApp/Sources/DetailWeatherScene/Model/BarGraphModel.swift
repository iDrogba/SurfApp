//
//  BarGraphModel.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/21.
//

import UIKit

struct BarGraphModel {
    let color: UIColor
    let topPoint: CGFloat
    let bottomPoint: CGFloat
    let width: CGFloat
    let value1: String
    let value2: String
    let icon: UIImage
    
    init(color: UIColor, topPoint: CGFloat, bottomPoint: CGFloat, width: CGFloat, value1: String, value2: String, icon: UIImage) {
        self.color = color
        self.topPoint = topPoint
        self.bottomPoint = bottomPoint
        self.width = width
        self.value1 = value1
        self.value2 = value2
        self.icon = icon
    }
}
