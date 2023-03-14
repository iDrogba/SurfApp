//
//  SavedRegionManager.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/14.
//

import Foundation
import MapKit

class SavedRegionManager {
    static let shared = SavedRegionManager()
    private let userDefaults = UserDefaults.standard
    private let userDefaultsKey = "SavedRegionManagerKey"
    var savedRegions: [RegionModel] = []

    init() {
        do{
            guard let savedData = userDefaults.value(forKey: userDefaultsKey) as? Data else {
                return
            }
            
            let decodedData = try PropertyListDecoder().decode([RegionModel].self, from: savedData)
            self.savedRegions = decodedData
        }catch {
            print(error)
        }
    }

    func sortSavedRegions() -> [RegionModel] {
        let returnVal = SavedRegionManager.shared.savedRegions.sorted(by: <)
        return returnVal
    }
    
    /// UserDefaults에 RegionModel 추가.
    func saveRegion(_ model: RegionModel) {
        do{
            guard let savedData = userDefaults.value(forKey: userDefaultsKey) as? Data else {
                var modelArray: [RegionModel] = []
                modelArray.append(model)
                userDefaults.set(try PropertyListEncoder().encode(modelArray), forKey: userDefaultsKey)
                
                return
            }
            
            var decodedData = try PropertyListDecoder().decode([RegionModel].self, from: savedData)
            decodedData.append(model)
            
            userDefaults.set(try PropertyListEncoder().encode(decodedData.uniqued()), forKey: userDefaultsKey)
        } catch {
            print(error)
        }
    }
    
    ///  UserDefaults에 RegionModel 삭제.
    func removeSavedRegion(_ model: RegionModel) {
        do {
            guard let savedData = userDefaults.value(forKey: userDefaultsKey) as? Data else {
                return
            }
            
            var decodedData = try PropertyListDecoder().decode([RegionModel].self, from: savedData)
            guard let removeIndex = decodedData.firstIndex(of: model) else {
                return
            }
            decodedData.remove(at: removeIndex)
            
            userDefaults.set(try PropertyListEncoder().encode(decodedData.uniqued()), forKey: userDefaultsKey)
        } catch {
            print(error)
        }
    }
}
