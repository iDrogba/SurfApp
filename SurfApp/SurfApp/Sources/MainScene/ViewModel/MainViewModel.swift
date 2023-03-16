//
//  MainViewModel.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/03.
//

import Foundation
import MapKit
import RxCocoa
import RxSwift

class MainViewModel {
    var searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()
    var searchResults = PublishSubject<[MKLocalSearchCompletion]>()
    
    let disposeBag = DisposeBag()
    let favoriteRegionWeathers = PublishSubject<[RegionModel:[WeatherModel]]>()
    let favoriteRegionTodayWeathers = PublishSubject<[RegionModel:[WeatherModel]]>()
    
    init() {
        setSearchCompleter()
        setFavoriteRegionWeathers()
        setFavoriteRegionTodayWeathers()
    }
    
    private func setSearchCompleter() {
        searchCompleter.resultTypes = .pointOfInterest
        searchCompleter.pointOfInterestFilter = MKPointOfInterestFilter.init(including: [.beach])
    }
    
    private func setFavoriteRegionWeathers() {
        let regions = SavedRegionManager.shared.sortSavedRegions()
        StormglassNetworking.shared.requestWeather(regions: regions)
            .bind(to: favoriteRegionWeathers)
            .disposed(by: disposeBag)
    }
    
    private func setFavoriteRegionTodayWeathers() {
        favoriteRegionWeathers
            .map{
                var sortedWeathers: [RegionModel:[WeatherModel]] = [:]
                $0.forEach {
                    sortedWeathers[$0.key] = $0.value.getTodayWeather()
                }
                return sortedWeathers
            }
            .bind(to: favoriteRegionTodayWeathers)
            .disposed(by: disposeBag)
    }
}
