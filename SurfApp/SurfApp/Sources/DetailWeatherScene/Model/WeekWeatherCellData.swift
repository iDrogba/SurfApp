//
//  WeekWeatherModel.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/30.
//

import Foundation

struct WeekWeatherCellData {
    let day: String
    let date: String
    let weather: String
    let minMaxTemparature: String
    
    init(weathers: [WeatherModel]) {
        day = (weathers.first?.date.weekDay()) ?? "요일"
        date = weathers.first?.date.monthAndDay() ?? "1.1"
        weather = "wind"
        let minMaxTemparature = weathers.minMaxTemparature()
        self.minMaxTemparature = Int(minMaxTemparature.max).description + "/" + Int(minMaxTemparature.min).description
    }
}
