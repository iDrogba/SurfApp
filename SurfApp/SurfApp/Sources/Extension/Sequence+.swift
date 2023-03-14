//
//  Sequence+.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/14.
//

import Foundation

extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}
