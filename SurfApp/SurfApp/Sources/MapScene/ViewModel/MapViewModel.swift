//
//  MapViewModel.swift
//  SurfApp
//
//  Created by 김상현 on 2023/04/23.
//

import Foundation
import MapKit
import RxSwift

class MapViewModel {
    let disposeBag = DisposeBag()
    let defaultRegion = ReplaySubject<[RegionModel]>.create(bufferSize: 1)
    let defaultRegionAnnotations = ReplaySubject<[MKPointAnnotation]>.create(bufferSize: 1)
    
    let regionData = ReplaySubject<[RegionModel:FavoriteRegionCellData]>.create(bufferSize: 1)
    let favoriteRegionAnnotations = ReplaySubject<[MKPointAnnotation:FavoriteRegionCellData]>.create(bufferSize: 1)
    
    let selectedMapLocation = ReplaySubject<RegionModel>.create(bufferSize: 1)
    let selectedMapLocationData = PublishSubject<FavoriteRegionCellData>()
    
    init() {
        loadDefaultRegionData()
        setDefaultRegionAnnotations()
        setFavoriteRegionAnnotations()
        
        Observable
            .combineLatest(selectedMapLocation.asObservable(), regionData)
            .map { (region, regionData) in
                if let favoriteRegionData = regionData[region] {
                    return favoriteRegionData
                } else {
                    
                    StormglassNetworking.shared.requestWeather(region: region)
                        .take(1)
                        .subscribe(onNext: {
                            self.appendToRegionData(weathers: (region, $0))
                        })
                        .disposed(by: self.disposeBag)
                    
                    return FavoriteRegionCellData.fetchDefaultData(region: region)
                }
            }
            .bind(to: selectedMapLocationData)
            .disposed(by: disposeBag)
    }
    
    private func loadDefaultRegionData() {
        let fileName: String = "DefaultRegionData"
        let extensionType = "json"
        
        guard let fileLocation = Bundle.main.url(forResource: fileName, withExtension: extensionType) else { return }
        
        do {
            let data = try Data(contentsOf: fileLocation)
            let defaultRegions = try JSONDecoder().decode([RegionModel].self, from: data)

            defaultRegion.onNext(defaultRegions)
        } catch {
        }
    }
    
    private func setDefaultRegionAnnotations() {
        Observable
            .combineLatest(defaultRegion, regionData)
            .map { (defaultRegion, regionData) in
                
                let defaultRegion = defaultRegion.filter {
                    !regionData.keys.contains($0)
                }
                
                return defaultRegion.map {
                    let latitude = Double($0.latitude) ?? 0
                    let longitude = Double($0.longitude) ?? 0
                    
                    let pin = MKPointAnnotation()
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    pin.coordinate = coordinate
                    pin.title = $0.regionName
                    pin.subtitle = $0.locality
                    
                    return pin
                }
            }
            .bind(to: defaultRegionAnnotations)
            .disposed(by: disposeBag)
    }
    
    private func setFavoriteRegionAnnotations() {
        Observable
            .combineLatest(SavedRegionManager.shared.savedFavoriteRegionSubject, regionData)
            .map { (favoriteRegion, regionData) in
                var newDictionary: [MKPointAnnotation:FavoriteRegionCellData] = [:]
                
                regionData.forEach {
                    if favoriteRegion.contains($0.key) {
                        let latitude = Double($0.key.latitude) ?? 0
                        let longitude = Double($0.key.longitude) ?? 0
                        
                        let pin = MKPointAnnotation()
                        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        pin.coordinate = coordinate
                        pin.title = $0.key.regionName
                        pin.subtitle = $0.key.locality
                        
                        newDictionary[pin] = $0.value
                    }
                }
                
                return newDictionary
            }
            .bind(to: favoriteRegionAnnotations)
        .disposed(by: disposeBag)
    }
    
    func updateSelectedMapLocation(regionName: String?, locality: String?) {
        Observable
            .combineLatest(SavedRegionManager.shared.savedFavoriteRegionSubject, SavedRegionManager.shared.defaultRegionSubject)
            .take(1)
            .subscribe(onNext: { (favoriteRegions, defaultRegions) in
                let regions = favoriteRegions + defaultRegions
                
                if let regionModel = regions.first(where: {$0.regionName == regionName && $0.locality == locality}) {
                    self.selectedMapLocation.onNext(regionModel)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func appendToRegionData(weathers: (RegionModel, [WeatherModel])) {
        
        regionData
            .take(1)
            .subscribe(onNext: {
                var returnDic: [RegionModel:FavoriteRegionCellData] = $0

                guard let favoriteRegionCellData = FavoriteRegionCellData.convertWeatherModels(weathers: weathers.1) else { return }
                returnDic[weathers.0] = favoriteRegionCellData
                
                self.regionData.onNext(returnDic)
            })
            .disposed(by: disposeBag)
        
    }
}
