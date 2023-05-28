//
//  SavedRegionManager.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/14.
//

import Foundation
import MapKit
import RxSwift

class SavedRegionManager {
    static let shared = SavedRegionManager()
    private let userDefaults = UserDefaults.standard
    private let userDefaultsKey = "SavedRegionManagerKey"

    let savedFavoriteRegionSubject = ReplaySubject<[RegionModel]>.create(bufferSize: 1)
    let sortedSavedRegionSubject = ReplaySubject<[RegionModel]>.create(bufferSize: 1)
    let defaultRegionSubject = ReplaySubject<[RegionModel]>.create(bufferSize: 1)
    let disposeBag = DisposeBag()
    
    init() {
        setSortedSavedRegionSubject()
        setSavedRegionSubject()
        synchronizeSavedRegion()
        loadDefaultRegionData()
    }
    
    private func setSavedRegionSubject() {
        Observable.create { observer in
            do{
                if let savedData = self.userDefaults.value(forKey: self.userDefaultsKey) as? Data {
                    let decodedData = try PropertyListDecoder().decode([RegionModel].self, from: savedData)
                    observer.onNext(decodedData)
                } else {
                    observer.onNext([])
                }
            } catch {
                print(error)
                observer.onCompleted()
            }
            return Disposables.create()
        }
        .bind(to: self.savedFavoriteRegionSubject)
        .disposed(by: disposeBag)
    }

    private func setSortedSavedRegionSubject() {
        savedFavoriteRegionSubject
            .map { $0.sorted(by: <) }
            .bind(to: sortedSavedRegionSubject)
            .disposed(by: disposeBag)
    }
    
    private func synchronizeSavedRegion() {
        savedFavoriteRegionSubject
            .subscribe { regions in
                do{
                    self.userDefaults.set(try PropertyListEncoder().encode(regions.uniqued()), forKey: self.userDefaultsKey)
                } catch {
                    print(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func loadDefaultRegionData() {
        let fileName: String = "DefaultRegionData"
        let extensionType = "json"
        
        guard let fileLocation = Bundle.main.url(forResource: fileName, withExtension: extensionType) else { return }
        
        do {
            let data = try Data(contentsOf: fileLocation)
            let defaultRegions = try JSONDecoder().decode([RegionModel].self, from: data)

            defaultRegionSubject.onNext(defaultRegions)
        } catch {
        }
    }
    
    
    /// UserDefaults에 RegionModel 추가.
    func saveRegion(_ model: RegionModel) {
        savedFavoriteRegionSubject
            .take(1)
            .subscribe { regions in
                if var regions = regions.element {
                    regions.append(model)
                    self.savedFavoriteRegionSubject.onNext(regions)
                }
            }
            .disposed(by: disposeBag)
    }
    
    ///  UserDefaults에 RegionModel 삭제.
    func removeSavedRegion(_ model: RegionModel) {
        savedFavoriteRegionSubject
            .take(1)
            .subscribe { regions in
                if var regions = regions.element {
                    regions.removeAll {
                        $0 == model
                    }
                    self.savedFavoriteRegionSubject.onNext(regions)
                }
            }
            .disposed(by: disposeBag)
    }
}
