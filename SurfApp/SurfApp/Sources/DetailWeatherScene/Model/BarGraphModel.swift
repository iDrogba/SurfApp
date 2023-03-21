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
    
    init(color: UIColor, topPoint: CGFloat, bottomPoint: CGFloat, width: CGFloat) {
        self.color = color
        self.topPoint = topPoint
        self.bottomPoint = bottomPoint
        self.width = width
    }
}
