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

    func onTapFavoriteRegionCollectionView(region: RegionModel) {
        let event = "Main_onTapFavoriteRegionCollectionView"
        let parameter = region.asDictionary()
        
        Analytics.setUserID("userID: \(udid)")
        Analytics.logEvent(event, parameters: parameter)
    }
    
    func onTapWeekWeatherCollectionView() {
        let event = "DetailWeather_onTapWeekWeatherCollectionView"

        Analytics.setUserID("userID: \(udid)")
        Analytics.logEvent(event, parameters: nil)
    }
    
}
