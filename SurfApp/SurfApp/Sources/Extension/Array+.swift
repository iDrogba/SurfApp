//
//  Array+.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/16.
//

import Foundation

extension Array where Element == WeatherModel {
    func getTodayWeather() -> [WeatherModel] {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        
        let sortedWeather = self.filter {
            $0.isSameDate(components)
        }
        
        return sortedWeather
    }
    
    func getToday3HourWeather() -> [WeatherModel] {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .month, .year], from: date)
        
        var sortedWeather = self.filter {
            $0.isSameDate(components)
        }
        sortedWeather = sortedWeather.filter {
            $0.isDateMultiplyOf(hour: 3)
        }
        
        return sortedWeather
    }
}
