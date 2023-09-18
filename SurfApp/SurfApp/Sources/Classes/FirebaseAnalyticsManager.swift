//
//  FirebaseAnalyticsManager.swift
//  SurfApp
//
//  Created by 김상현 on 2023/09/17.
//

import Foundation
import FirebaseAnalytics

class FirebaseAnalyticsManager {
    static let shared = FirebaseAnalyticsManager()
    let udid = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
    
    init() {
        Analytics.setUserID("userID: \(udid)")
    }

    func onTapFavoriteRegionCollectionView(region: RegionModel) {
        let event = "Main_onTapFavoriteRegionCell"
        let parameter = region.asDictionary
        
        Analytics.logEvent(event, parameters: parameter)
    }
    
    func onTapWeekWeatherCollectionView(index: Int, day: String) {
        let event = "DetailWeather_onTapWeekWeatherCell"
        let parameter = [
            "요일": day,
            "몇일후": index.description
        ]

        Analytics.logEvent(event, parameters: parameter)
    }
    
}
