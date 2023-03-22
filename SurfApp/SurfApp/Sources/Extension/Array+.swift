//
//  Array+.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/16.
//

import Foundation

extension Array where Element == WeatherModel {
    func getCurrentWeather() -> WeatherModel? {
        let date = Date()
        let calendar = Calendar.current
        let calendarComponenets: Set<Calendar.Component> = [.hour, .day, .month, .year]
        let components = calendar.dateComponents(calendarComponenets, from: date)
        let sortedWeather = self.first(where: { $0.isSameDate(components, calendarComponents: calendarComponenets) })

        return sortedWeather
    }
    
    func getTodayWeather() -> [WeatherModel] {
        let date = Date()
        let calendar = Calendar.current
        let calendarComponenets: Set<Calendar.Component> = [.day, .month, .year]
        let components = calendar.dateComponents(calendarComponenets, from: date)
        
        let sortedWeather = self.filter {
            $0.isSameDate(components, calendarComponents: calendarComponenets)
        }

        return sortedWeather
    }
    
    func getToday3HourWeather() -> [WeatherModel] {
        let date = Date()
        let calendar = Calendar.current
        let calendarComponenets: Set<Calendar.Component> = [.day, .month, .year]
        let components = calendar.dateComponents(calendarComponenets, from: date)
        
        var sortedWeather = self.filter {
            $0.isSameDate(components, calendarComponents: calendarComponenets)
        }
        sortedWeather = sortedWeather.filter {
            $0.isDateMultiplyOf(hour: 3)
        }
        
        return sortedWeather
    }
}
