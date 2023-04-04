//
//  StormglassResponse.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/03.
//

import Foundation

struct StormglassResponse: Codable {
    let weather: [Weather]
    let meta: Meta
    
    enum CodingKeys: String, CodingKey {
        case weather = "hours"
        case meta
    }
}

struct Weather: Codable {
    let time: Date
    let airTemperature, waveHeight, wavePeriod, waveDirection, windSpeed, windDirection, cloudCover, precipitation, snowDepth: [String: Double]?
}

struct Meta: Codable {
    let dailyQuota: Double
    let lat: Double
    let lng: Double
    let requestCount: Double
}
