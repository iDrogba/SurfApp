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
    let favoriteRegionData = PublishSubject<[RegionModel:FavoriteRegionCellData]>()
    let mapAnnotations = ReplaySubject<[MKPointAnnotation:FavoriteRegionCellData]>.create(bufferSize: 1)
    
    let selectedMapLocation = ReplaySubject<RegionModel>.create(bufferSize: 1)
    let selectedMapLocationData = PublishSubject<FavoriteRegionCellData>()
    
    init() {
        favoriteRegionData.map {
            var newDictionary: [MKPointAnnotation:FavoriteRegionCellData] = [:]
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
        .bind(to: mapAnnotations)
        .disposed(by: disposeBag)
        
        Observable
            .combineLatest(selectedMapLocation.asObservable(), favoriteRegionData)
            .map { $1[$0]! }
            .bind(to: selectedMapLocationData)
            .disposed(by: disposeBag)
            
    }
    
    func updateSelectedMapLocation(regionName: String?, locality: String?) {
        SavedRegionManager.shared.savedRegionSubject
            .take(1)
            .subscribe(onNext: {
                if let regionModel = $0.first(where: {$0.regionName == regionName && $0.locality == locality}) {
                    self.selectedMapLocation.onNext(regionModel)
                }
            })
            .disposed(by: disposeBag)
    }
}
