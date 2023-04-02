//
//  WeekWeatherModel.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/30.
//

import Foundation

struct WeekWeatherCellData {
    var isToday: Bool
    var isWeekEnd: Bool
    var day: String
    let date: String
    let weather: String
    let minMaxTemparature: String
    
    init(weathers: [WeatherModel]) {
        isToday = false
        isWeekEnd = false
        day = weathers.first!.date.weekDay()
        date = weathers.first?.date.monthAndDay() ?? "1.1"
        weather = "wind"
        let minMaxTemparature = weathers.minMaxTemparature()
        self.minMaxTemparature = Int(minMaxTemparature.max).description + "/" + Int(minMaxTemparature.min).description
        
        if self.day == "토" || self.day == "일" {
            self.isWeekEnd = true
        }
        
        if weathers.first!.date.isToday() {
            self.isToday = true
            self.day = "오늘"
        }
    }
}
