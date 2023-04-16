//
//  WeatherModel.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/11.
//

import Foundation
import MapKit

struct WeatherModel {
    var regionModel: RegionModel
    var date: Date = Date()
    var airTemperature: Double = 0
    var waveHeight: Double = 0
    var wavePeriod: Double = 0
    var waveDirection: Double = 0
    var windSpeed: Double = 0
    var windDirection: Double = 0
    var cloudCover: Double = 0 //맑음 = 0/10~2/10, 구름조금 = 3/10~5/10, 구름많음 = 6/10~8/10, 흐림 = 9/10~10/10.
    var precipitation: Double = 0 //강수량
    var snowDepth: Double = 0
    var weatherCondition: String = ""

    init(_ regionModel: RegionModel, _ weather: Weather) {
        self.regionModel = regionModel
        self.date = weather.time
        self.airTemperature = averageVal(data: weather.airTemperature, rounder: 10)
        self.waveHeight = averageVal(data: weather.waveHeight, rounder: 100)
        self.wavePeriod = averageVal(data: weather.wavePeriod, rounder: 10)
        self.waveDirection = averageVal(data: weather.waveDirection, rounder: 100)
        self.windSpeed = averageVal(data: weather.windSpeed, rounder: 10)
        self.windDirection = averageVal(data: weather.windDirection, rounder: 10)
        self.cloudCover = averageVal(data: weather.cloudCover, rounder: 1)
        self.precipitation = averageVal(data: weather.precipitation, rounder: 100)
        self.snowDepth = averageVal(data: weather.snowDepth, rounder: 10)
        self.weatherCondition = WeatherCondition.makeWeatherCondition(precipitation: self.precipitation, cloudCover: self.cloudCover, snowDepth: self.snowDepth)
    }
    
    private func averageVal(data: [String:Double]?, rounder: Double) -> Double {
        guard let data = data else { return 0 }
        var sum = data.values.reduce(0, { first, second in
            return (first + second)
        })
        sum /=  Double(data.count)
        sum = round(sum * rounder) / rounder
        return sum
    }
    
    func isSameDate(_ dateComponents: DateComponents, calendarComponents: Set<Calendar.Component>) -> Bool {
        let calendar = Calendar.current
        let modelComponents = calendar.dateComponents(calendarComponents, from: self.date)
        
        if modelComponents == dateComponents {
            return true
        } else {
            return false
        }
    }
    
    func isDateAfter(_ dateComponents: DateComponents, calendarComponents: Set<Calendar.Component>) -> Bool {
        let calendar = Calendar.current
        let modelComponents = calendar.dateComponents(calendarComponents, from: self.date)
        let modelDayCount = 365 * modelComponents.year! + 31 * modelComponents.month! + modelComponents.day!
        let targetDayCount = 365 * dateComponents.year! + 31 * dateComponents.month! + dateComponents.day!

        if modelDayCount >= targetDayCount {
            return true
        } else {
            return false
        }
    }
    
    func isDateMultiplyOf(hour: Int) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: self.date)
        
        if let modelHour = components.hour, modelHour % hour == 0 {
            return true
        } else {
            return false
        }
    }
}

class WeatherModelManager {
    static let shared = WeatherModelManager()
    var weatherModels: [RegionModel:[WeatherModel]] = [:]
}

//class UpdatedWeatherForecastModelManager {
//    static let shared = UpdatedWeatherForecastModelManager()
//    /**
//     행정구역을 키값으로 날씨 예보 모델을 구분한 딕셔너리.
//
//     [행정구역 코드 : [날씨 예보 모델]]
//     */
//    var weatherForecastModels: [MKPlacemark:[WeatherModel]] = [:]
//
//    // 오늘 24시간 동안의 데이터 가져오기
//    func retrieveTodayWeatherFoercastModels() async -> [MKRegionDataModel:[UpdatedWeatherForecastModel]] {
//        var returnValue: [MKRegionDataModel:[UpdatedWeatherForecastModel]] = [:]
//        returnValue = UpdatedWeatherForecastModelManager.shared.weatherForecastModels
//        UpdatedWeatherForecastModelManager.shared.weatherForecastModels.forEach{
//            if $0.value.count > 24 {
//                returnValue[$0.key]?[24 ..< ($0.value.count)] = []
//            }
//        }
//        return returnValue
//    }
//
//    /// 현시각을 포함하여 앞으로의 예보 모델 가져온다.
//    func retrieveWeatherForecastModelsAfterCurrentTime(regionModel: MKRegionDataModel) async -> [UpdatedWeatherForecastModel] {
//        guard let returnVal = UpdatedWeatherForecastModelManager.shared.weatherForecastModels[regionModel]?.filter({($0.time - Date.dateA) >= -3600}) else { return [] }
//        return returnVal
//    }
//
//    func appendCurrentWeatherForecastModels(regionModel: MKRegionDataModel, hours: [Hours]) async {
//        if self.weatherForecastModels[regionModel] == nil {
//            self.weatherForecastModels[regionModel] = []
//        }
//        hours.forEach{
//            let model = UpdatedWeatherForecastModel(regionModel, $0)
//            self.weatherForecastModels[regionModel]?.append(model)
//        }
//    }
//
//    func removeWeatherForecastModels(regionModel: MKRegionDataModel) async {
//        self.weatherForecastModels.removeValue(forKey: regionModel)
//    }
//}
