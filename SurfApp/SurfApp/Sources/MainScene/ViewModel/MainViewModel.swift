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
    let savedRegions = ReplaySubject<[RegionModel]>.create(bufferSize: 1)
    let favoriteRegionWeathers = PublishSubject<[RegionModel:[WeatherModel]]>()
    let favoriteRegionTodayWeathers = PublishSubject<[RegionModel:[WeatherModel]]>()
    let favoriteRegionCurrentWeathers = PublishSubject<[RegionModel:WeatherModel]>()
    let favoriteRegionCellData = PublishSubject<[RegionModel:FavoriteRegionCellData]>()
    
    init() {
        setSearchCompleter()
        setSavedRegions()
        setFavoriteRegionWeathers()
        setFavoriteRegionTodayWeathers()
        setFavoriteRegionCurrentWeathers()
        
        favoriteRegionTodayWeathers
            .map {
                self.convertToFavoriteRegionCellData(weathers: $0)
            }
            .bind(to: favoriteRegionCellData)
            .disposed(by: disposeBag)
        
    }
    
    private func setSearchCompleter() {
        searchCompleter.resultTypes = .pointOfInterest
        searchCompleter.pointOfInterestFilter = MKPointOfInterestFilter.init(including: [.beach])
    }
    
    private func setSavedRegions() {
        SavedRegionManager.shared.sortedSavedRegionSubject
            .bind(to: self.savedRegions)
            .disposed(by: disposeBag)
    }
    
    private func setFavoriteRegionWeathers() {
        savedRegions.subscribe { regions in
            
            StormglassNetworking.shared.requestWeather(regions: regions)
                .bind(to: self.favoriteRegionWeathers)
                .disposed(by: self.disposeBag)
            
        }
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
    
    private func setFavoriteRegionCurrentWeathers() {
        favoriteRegionWeathers
            .map {
                var sortedWeathers: [RegionModel:WeatherModel] = [:]
                $0.forEach {
                    sortedWeathers[$0.key] = $0.value.getCurrentWeather()
                }

                return sortedWeathers
            }
            .bind(to: favoriteRegionCurrentWeathers)
            .disposed(by: disposeBag)
    }
    
    private func convertToFavoriteRegionCellData(weathers: [RegionModel:[WeatherModel]]) -> [RegionModel:FavoriteRegionCellData] {
        var returnDic: [RegionModel:FavoriteRegionCellData] = [:]
        
        weathers.forEach {
            guard let currentWeather = $0.value.getCurrentWeather() else {
                return
            }
            
            let minMaxWaveHeight = $0.value.minMaxWaveHeight()
            
            returnDic[$0.key] = FavoriteRegionCellData(region: currentWeather.regionModel, minMaxWaveHeight: minMaxWaveHeight, windSpeed: currentWeather.windSpeed, cloudCover: currentWeather.cloudCover, precipitation: currentWeather.precipitation, temparature: currentWeather.airTemperature)
        }
        
        return returnDic
    }

    func getRegionWeathers(region: RegionModel) -> Observable<[WeatherModel]> {
        favoriteRegionWeathers
            .map {
                $0[region]!
            }
    }
}
