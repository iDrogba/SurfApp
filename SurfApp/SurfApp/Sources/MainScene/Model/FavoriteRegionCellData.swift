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
    
    static func fetchDefaultData(region: RegionModel) -> FavoriteRegionCellData {
        return FavoriteRegionCellData(region: region, minMaxWaveHeight: (min: 0, max: 0), windSpeed: 0, cloudCover: 0, precipitation: 0, temparature: 0, weatherCondition: "", surfCondition: ("날씨를 불러옵니다.", .customRed))
    }
    
    static func convertWeatherModels(weathers: [WeatherModel]) -> FavoriteRegionCellData? {
        guard let currentWeather = weathers.getCurrentWeather() else {
            return nil
        }
        
        let minMaxWaveHeight = weathers.minMaxWaveHeight()
        
        return FavoriteRegionCellData(region: currentWeather.regionModel, minMaxWaveHeight: minMaxWaveHeight, windSpeed: currentWeather.windSpeed, cloudCover: currentWeather.cloudCover, precipitation: currentWeather.precipitation, temparature: currentWeather.airTemperature, weatherCondition: currentWeather.weatherCondition, surfCondition: currentWeather.surfCondition)
    }
}
