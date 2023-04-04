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
    
    func sliceBySameDate() -> [[WeatherModel]] {
        let calendar = Calendar.current
        let calendarComponenets: Set<Calendar.Component> = [.day, .month, .year]
        
        var dates: [DateComponents] = []
        var sortedWeathers: [DateComponents:[WeatherModel]] = [:]

        self.forEach {
            let components = calendar.dateComponents(calendarComponenets, from: $0.date)
            
            if !dates.contains(components) {
                dates.append(components)
            }
            
            if sortedWeathers[components] == nil {
                sortedWeathers[components] = [$0]
            } else {
                sortedWeathers[components]?.append($0)
            }
        }
        
        let returnValue = dates.map {
            return sortedWeathers[$0]!
        }
        
        return returnValue
    }
    
    // 해당 일 이후 모든 weathermodel
    func getWeatherAfter(day: Date) -> [WeatherModel] {
        let calendar = Calendar.current
        let calendarComponenets: Set<Calendar.Component> = [.day, .month, .year]
        let components = calendar.dateComponents(calendarComponenets, from: day)
        
        let sortedWeather = self.filter {
            $0.isDateAfter(components, calendarComponents: calendarComponenets)
        }
        
        return sortedWeather
    }
    
    func minMaxTemparature() -> (min:Double, max:Double) {
        var maxTemp = self.first?.airTemperature ?? 0
        var minTemp = self.first?.airTemperature ?? 0
        
        self.forEach {
            if maxTemp < $0.airTemperature {
                maxTemp = $0.airTemperature
            }
            
            if minTemp > $0.airTemperature {
                minTemp = $0.airTemperature
            }
        }
        
        return (min: minTemp, max:maxTemp)
    }
    
    func minMaxWaveHeight() -> (min:Double, max:Double) {
        var maxHeight = self.first?.waveHeight ?? 0
        var minHeight = self.first?.waveHeight ?? 0
        
        self.forEach {
            if maxHeight < $0.waveHeight {
                maxHeight = $0.waveHeight
            }
            
            if minHeight > $0.waveHeight {
                minHeight = $0.waveHeight
            }
        }
        
        return (min: minHeight, max:maxHeight)
    }
}
