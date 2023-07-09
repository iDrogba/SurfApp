//
//  WeatherCondition.swift
//  SurfApp
//
//  Created by 김상현 on 2023/04/16.
//

import UIKit

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
    
    static func makeSurfCondition(waveHeight: Double) -> (String, UIColor) {
        var waveHeightConditionDescription = ""
        var representColor: UIColor = .customBlue
        
        switch waveHeight {
        case ...0.5:
            waveHeightConditionDescription = "The waves are too shallow.".localized
            representColor = .customBlue
        case 0.5 ... 1:
            waveHeightConditionDescription = "It's good for beginners to enjoy.".localized
            representColor = .cyan
        case 1 ... 1.5:
            waveHeightConditionDescription = "It's good for intermediate to enjoy.".localized
            representColor = .customGreen
        case 1.5 ... 2.0:
            waveHeightConditionDescription = "It's good for advanced to enjoy.".localized
            representColor = .customYellow
        default:
            waveHeightConditionDescription = "The waves are too high.".localized
            representColor = .customRed
        }
        
        return (waveHeightConditionDescription, representColor)
    }
}
