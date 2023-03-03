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
}

struct Weather: Codable {
    let time: String
    let airTemperature, waveHeight, wavePeriod, waveDirection, windSpeed, cloudCover, precipitation, snowDepth: [String: Double]?
}

struct Meta: Codable {
    let dailyQuota: Double
    let lat: Double
    let lng: Double
    let requestCount: Double
}
