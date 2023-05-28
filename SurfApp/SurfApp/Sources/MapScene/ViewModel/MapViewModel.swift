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
    let defaultRegion = ReplaySubject<[RegionModel]>.create(bufferSize: 1)
    let defaultRegionAnnotation = ReplaySubject<[MKPointAnnotation]>.create(bufferSize: 1)
    let mapAnnotations = ReplaySubject<[MKPointAnnotation:FavoriteRegionCellData]>.create(bufferSize: 1)
    
    let selectedMapLocation = ReplaySubject<RegionModel>.create(bufferSize: 1)
    let selectedMapLocationData = PublishSubject<FavoriteRegionCellData>()
    
    init() {
        loadDefaultRegionData()
        setDefaultRegionAnnotation()
        
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
            .filter({ $1[$0] != nil })
            .map { $1[$0]! }
            .bind(to: selectedMapLocationData)
            .disposed(by: disposeBag)
    }
    
    func loadDefaultRegionData() {
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
    
    func setDefaultRegionAnnotation() {
        defaultRegion
            .map({
                $0.map {
                    let latitude = Double($0.latitude) ?? 0
                    let longitude = Double($0.longitude) ?? 0
                    
                    let pin = MKPointAnnotation()
                    let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    pin.coordinate = coordinate
                    pin.title = $0.regionName
                    pin.subtitle = $0.locality
                    
                    return pin
                }
            })
            .bind(to: defaultRegionAnnotation)
            .disposed(by: disposeBag)
    }
    
    func updateSelectedMapLocation(regionName: String?, locality: String?) {
        SavedRegionManager.shared.savedFavoriteRegionSubject
            .take(1)
            .subscribe(onNext: {
                if let regionModel = $0.first(where: {$0.regionName == regionName && $0.locality == locality}) {
                    self.selectedMapLocation.onNext(regionModel)
                }
            })
            .disposed(by: disposeBag)
    }
}
