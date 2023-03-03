//
//  Networking.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/03.
//

import Foundation
import Alamofire
import RxSwift

class StormglassNetworking {
    static let shared = StormglassNetworking()
    
    private let url = "https://api.stormglass.io/v2/weather/point"
    private var parameters = ["params": "airTemperature, waveHeight, wavePeriod, waveDirection, windSpeed, cloudCover, precipitation, snowDepth"]
    
    func requestWeather(region: MKRegionModel) -> Observable<StormglassResponse> {
        
        return Observable.create { observer in
            self.parameters["start"] = Date.yesterdayUTC.timeIntervalSince1970.description
            self.parameters["lat"] = region.latitude
            self.parameters["lng"] = region.longitude
            
            let task = AF.request(self.url,
                                  method: .get,
                                  parameters: self.parameters,
                                  encoding: URLEncoding.default,
                                  headers: ["Authorization": APIKey().stormGlassAPIKey, "Content-Type":"application/json", "Accept":"application/json"])
                .validate(statusCode: 200..<300)
                .responseDecodable(of: StormglassResponse.self) { response in
                    switch response.result {
                    case .success(let response):
                        observer.onNext(response)
                    case .failure(let error):
                        observer.onError(error)
                    }
                    
                    observer.onCompleted()
                }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
        
    }
}
