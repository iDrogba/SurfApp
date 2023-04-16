//
//  WeatherCondition.swift
//  SurfApp
//
//  Created by 김상현 on 2023/04/16.
//

import Foundation

struct WeatherCondition {
    static func makeWeatherCondition(precipitation: Double, cloudCover: Double, snowDepth: Double) -> String {
        var clo = ""
        var pre = ""
        var sno = ""
        
        switch cloudCover {
        case ...0.5:
            clo = "sunny"
        default:
            clo = "cloudy"
        }
        
        switch precipitation {
        case ...0.1:
            pre = ""
        default:
            clo = "cloudy"
            pre = "Rainy"
        }
        
        switch snowDepth {
        case ...0.1:
            sno = ""
        default:
            clo = "cloudy"
            sno = "Snow"
        }
        
        // sunny, cloudy, cloudyRainy cloudySnow, cloRaiSno
        
        // precipitation > 0.1 -> rainy
        // cloudCover < 0.5 -> sunny / cloudy
        // snowDepth > 0.1 -> snow
        
        return clo + pre + sno
    }
}
