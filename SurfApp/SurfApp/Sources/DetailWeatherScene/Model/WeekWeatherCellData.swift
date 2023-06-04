//
//  WeekWeatherModel.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/30.
//

import UIKit

struct WeekWeatherCellData {
    var isToday: Bool
    var isWeekEnd: Bool
    var day: String
    let date: String
    let weather: String
    let minMaxWaveHeight: NSAttributedString
    
    init(weathers: [WeatherModel]) {
        isToday = false
        isWeekEnd = false
        day = weathers.first!.date.weekDay()
        date = weathers.first?.date.monthAndDay() ?? "1.1"
        weather = weathers.getRepresentativeWeatherCondition() ?? "wind"
        
        let minMaxWaveHeight = weathers.minMaxWaveHeight()
        
        let attrsForMin = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor : UIColor.customGray]
        let attrsForMax = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor : UIColor.black]
        let attributedStringForMin = NSMutableAttributedString(string:"\(minMaxWaveHeight.min)~\n", attributes:attrsForMin)
        let attributedStringForMax = NSMutableAttributedString(string:"\(minMaxWaveHeight.max)m", attributes:attrsForMax)
        
        attributedStringForMin.append(attributedStringForMax)
        self.minMaxWaveHeight = attributedStringForMin
        
        if self.day == "토" || self.day == "일" {
            self.isWeekEnd = true
        }
        
        if weathers.first!.date.isToday() {
            self.isToday = true
            self.day = "오늘"
        }
    }
}
