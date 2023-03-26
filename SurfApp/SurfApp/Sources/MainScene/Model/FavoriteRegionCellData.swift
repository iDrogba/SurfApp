//
//  FavoriteRegionCellData.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/26.
//

import Foundation

struct FavoriteRegionCellData {
    let region: RegionModel
    let minMaxWaveHeight: (min:Double, max:Double)
    let windSpeed: Double
    let temparature: Double
    let cloudCover: Double
    let precipitation: Double
    let surfCondition: String

    init(region: RegionModel, minMaxWaveHeight: (min: Double, max: Double), windSpeed: Double, cloudCover: Double, precipitation: Double, temparature: Double) {
        self.region = region
        self.minMaxWaveHeight = minMaxWaveHeight
        self.windSpeed = windSpeed
        self.temparature = temparature
        self.cloudCover = cloudCover
        self.precipitation = precipitation
        
        self.surfCondition = ""
    }
}
