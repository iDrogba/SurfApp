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
    let minMaxWaveHeights = PublishSubject<[RegionModel:(min:Double, max:Double)]>()
    
    init() {
        setSearchCompleter()
        setFavoriteRegionWeathers()
        setFavoriteRegionTodayWeathers()
        
        favoriteRegionWeathers
            .map {
                self.convertWeathersToMinMaxWaveHeight(weathers: $0)
            }
            .bind(to: minMaxWaveHeights)
            .disposed(by: disposeBag)
        
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
            .debug()
            .bind(to: favoriteRegionTodayWeathers)
            .disposed(by: disposeBag)
    }
    
    private func convertWeathersToMinMaxWaveHeight(weathers: [RegionModel:[WeatherModel]]) -> [RegionModel:(min:Double, max:Double)] {
        var returnDic: [RegionModel:(min:Double, max:Double)] = [:]
        
        weathers.forEach {
            guard let tempWaveHeight = $0.value.first?.waveHeight else {
                return
            }
            var minMaxWaveHeight: (min:Double, max:Double) = (min: tempWaveHeight, max: tempWaveHeight)
            $0.value.forEach {
                let waveHeight = $0.waveHeight
                if minMaxWaveHeight.min > waveHeight {
                    minMaxWaveHeight.min = waveHeight
                }
                if minMaxWaveHeight.max < waveHeight {
                    minMaxWaveHeight.max = waveHeight
                }
            }
            returnDic[$0.key] = minMaxWaveHeight
        }
        
        return returnDic
    }
}
