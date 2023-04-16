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

    let savedRegionSubject = ReplaySubject<[RegionModel]>.create(bufferSize: 1)
    let sortedSavedRegionSubject = ReplaySubject<[RegionModel]>.create(bufferSize: 1)
    let disposeBag = DisposeBag()
    
    init() {
        setSortedSavedRegionSubject()
        setSavedRegionSubject()
        synchronizeSavedRegion()
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
        .bind(to: self.savedRegionSubject)
        .disposed(by: disposeBag)
    }

    private func setSortedSavedRegionSubject() {
        savedRegionSubject
            .map { $0.sorted(by: <) }
            .bind(to: sortedSavedRegionSubject)
            .disposed(by: disposeBag)
    }
    
    private func synchronizeSavedRegion() {
        savedRegionSubject
            .subscribe { regions in
                do{
                    self.userDefaults.set(try PropertyListEncoder().encode(regions.uniqued()), forKey: self.userDefaultsKey)
                } catch {
                    print(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
    /// UserDefaults에 RegionModel 추가.
    func saveRegion(_ model: RegionModel) {
        savedRegionSubject
            .take(1)
            .subscribe { regions in
                if var regions = regions.element {
                    regions.append(model)
                    self.savedRegionSubject.onNext(regions)
                }
            }
            .disposed(by: disposeBag)
    }
    
    ///  UserDefaults에 RegionModel 삭제.
    func removeSavedRegion(_ model: RegionModel) {
        savedRegionSubject
            .take(1)
            .subscribe { regions in
                if var regions = regions.element {
                    regions.removeAll {
                        $0 == model
                    }
                    self.savedRegionSubject.onNext(regions)
                }
            }
            .disposed(by: disposeBag)
    }
}
