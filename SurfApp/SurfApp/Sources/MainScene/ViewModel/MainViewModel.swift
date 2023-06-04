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
    let favoriteRegionWeathers = PublishSubject<[RegionModel:[WeatherModel]?]>()
    let favoriteRegionTodayWeathers = PublishSubject<[RegionModel:[WeatherModel]?]>()
    let favoriteRegionCurrentWeathers = PublishSubject<[RegionModel:WeatherModel?]>()
    let favoriteRegionCellData = ReplaySubject<[RegionModel:FavoriteRegionCellData]>.create(bufferSize: 1)
    
    init() {
        setSearchCompleter()
        setSavedRegions()
        setFavoriteRegionTodayWeathers()
        setFavoriteRegionCurrentWeathers()
        setFavoriteRegionCellData()
        setFavoriteRegionWeathers()
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
            var placeholderDatas: [RegionModel:[WeatherModel]?] = [:]
            
            regions.forEach {
                placeholderDatas.updateValue(nil, forKey: $0)
            }

            self.favoriteRegionWeathers.onNext(placeholderDatas)
            
            StormglassNetworking.shared.requestWeather(regions: regions)
                .bind(to: self.favoriteRegionWeathers)
                .disposed(by: self.disposeBag)
            
        }
        .disposed(by: disposeBag)
    }
    
    private func setFavoriteRegionTodayWeathers() {
        favoriteRegionWeathers
            .map{
                var sortedWeathers: [RegionModel:[WeatherModel]?] = [:]
                $0.forEach {
                    if let weathers = $0.value {
                        sortedWeathers[$0.key] = weathers.getTodayWeather()
                    } else {
                        sortedWeathers.updateValue(nil, forKey: $0.key)
                    }
                }
                return sortedWeathers
            }
            .bind(to: favoriteRegionTodayWeathers)
            .disposed(by: disposeBag)
    }
    
    private func setFavoriteRegionCurrentWeathers() {
        favoriteRegionWeathers
            .map {
                var sortedWeathers: [RegionModel:WeatherModel?] = [:]
                $0.forEach {
                    if let weathers = $0.value {
                        sortedWeathers[$0.key] = weathers.getCurrentWeather()
                    } else {
                        sortedWeathers.updateValue(nil, forKey: $0.key)
                    }
                }

                return sortedWeathers
            }
            .bind(to: favoriteRegionCurrentWeathers)
            .disposed(by: disposeBag)
    }
    
    private func setFavoriteRegionCellData() {
        favoriteRegionWeathers
            .map {
                return self.convertToFavoriteRegionCellData(weathers: $0)
            }
            .bind(to: favoriteRegionCellData)
            .disposed(by: disposeBag)
    }
    
    private func convertToFavoriteRegionCellData(weathers: [RegionModel:[WeatherModel]?]) -> [RegionModel:FavoriteRegionCellData] {
        var returnDic: [RegionModel:FavoriteRegionCellData] = [:]
        
        weathers.forEach {
            if let weatherModels = $0.value {
                returnDic[$0.key] = FavoriteRegionCellData.convertWeatherModels(weathers: weatherModels)
            } else {
                let defaultCellData = FavoriteRegionCellData.fetchDefaultData(region: $0.key)
                returnDic[$0.key] = defaultCellData
            }
        }

        return returnDic
    }
}
