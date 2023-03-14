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
    let disposeBag = DisposeBag()
    
    var searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()
    var searchResults = PublishSubject<[MKLocalSearchCompletion]>()
    var favoriteRegionWeathers = PublishSubject<[RegionModel:[WeatherModel]]>()
    
    init() {
        setSearchCompleter()
        setFavoriteRegionWeathers()
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
}
