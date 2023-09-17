//
//  RegionModel.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/03.
//

import Foundation
import MapKit

struct RegionModel: Equatable, Codable, Hashable {
    let regionName: String
    let locality: String
    let subLocality: String
    let latitude: String
    let longitude: String
    
    init(placeMark: MKPlacemark) {
        self.regionName = placeMark.name ?? ""
        self.locality = placeMark.locality ?? ""
        self.subLocality = placeMark.subLocality ?? ""
        self.latitude = placeMark.coordinate.latitude.description
        self.longitude = placeMark.coordinate.longitude.description
    }
    
    public static func < (lhs: RegionModel, rhs: RegionModel) -> Bool {
        return lhs.regionName < rhs.regionName
    }
    
    public static func == (lhs: RegionModel, rhs: RegionModel) -> Bool {
        return lhs.regionName == rhs.regionName && lhs.locality == rhs.locality
    }
    
    func asDictionary() -> [String:Any] {
        let errorDictionary = ["Error":"dictionary parse error"]
        do {
            let jsonData = try self.jsonData()
            let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let dictionary = json as? [String:Any] else {
                return errorDictionary
            }
            
            return dictionary
        } catch {
            return errorDictionary
        }
    }
}
