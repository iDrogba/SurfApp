//
//  FavoriteRegionCellData.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/26.
//

import UIKit

struct FavoriteRegionCellData {
    let region: RegionModel
    let minMaxWaveHeight: (min:Double, max:Double)
    let windSpeed: Double
    let temparature: Double
    let cloudCover: Double
    let precipitation: Double
    let weatherCondition: String
    let surfCondition: (String, UIColor)

    init(region: RegionModel, minMaxWaveHeight: (min: Double, max: Double), windSpeed: Double, cloudCover: Double, precipitation: Double, temparature: Double, weatherCondition: String, surfCondition: (String, UIColor)) {
        self.region = region
        self.minMaxWaveHeight = minMaxWaveHeight
        self.windSpeed = windSpeed
        self.temparature = temparature
        self.cloudCover = cloudCover
        self.precipitation = precipitation
        self.weatherCondition = weatherCondition
        self.surfCondition = surfCondition
    }
}
