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
    let favoriteRegionCurrentWeathers = PublishSubject<[RegionModel:WeatherModel]>()
    let mapAnnotations = ReplaySubject<[MKPointAnnotation:WeatherModel]>.create(bufferSize: 1)
    
    init() {
//        Observable.combineLatest(SavedRegionManager.shared.savedRegionSubject, WeatherModelManager.shared.weatherModels)
        
//        if let weathers = WeatherModelManager.shared.weatherModels[region] {
//            Observable.create { observer in
//                observer.onNext(weathers)
//                return Disposables.create { }
//            }
//            .bind(to: self.weathers)
//            .disposed(by: disposeBag)
//        }
        
        
//        SavedRegionManager.shared.savedRegionSubject
//            .map { regions in
//                var newDictionary: [RegionModel:WeatherModel] = [:]
//
//                regions.forEach {
//                    newDictionary[$0] = WeatherModelManager.shared.weatherModels[$0]?.getCurrentWeather()
//                }
//
//                return newDictionary
//            }
//            .bind(to: favoriteRegionCurrentWeathers)
//            .disposed(by: disposeBag)
        
        favoriteRegionCurrentWeathers.map {
            var newDictionary: [MKPointAnnotation:WeatherModel] = [:]
            $0.forEach {
                let latitude = Double($0.key.latitude) ?? 0
                let longitude = Double($0.key.longitude) ?? 0

                let pin = MKPointAnnotation()
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                pin.coordinate = coordinate
                pin.title = $0.key.regionName
                pin.subtitle = $0.key.locality
                
                newDictionary[pin] = $0.value
            }

            return newDictionary
        }
        .debug()
        .bind(to: mapAnnotations)
        .disposed(by: disposeBag)
    }
    
}
