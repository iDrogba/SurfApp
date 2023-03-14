//
//  Networking.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/03.
//

import Foundation
import Alamofire
import RxSwift
import MapKit

class StormglassNetworking {
    static let shared = StormglassNetworking()
    
    private let url = "https://api.stormglass.io/v2/weather/point"
    private var parameters = ["params": "airTemperature,waveHeight,wavePeriod,waveDirection,windSpeed,cloudCover,precipitation,snowDepth"]
    
    private let customDecoder: JSONDecoder = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let customDecoder = JSONDecoder()
        customDecoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return customDecoder
    }()
    
    func requestWeather(region: RegionModel) -> Observable<[WeatherModel]> {
        
        return Observable.create { observer in
            self.parameters["start"] = Date.yesterdayUTC.timeIntervalSince1970.description
            self.parameters["lat"] = region.latitude
            self.parameters["lng"] = region.longitude
            
            let task = AF.request(self.url,
                                  method: .get,
                                  parameters: self.parameters,
                                  encoding: URLEncoding.default,
                                  headers: ["Authorization": APIKey().stormGlassAPIKey])
                .validate(statusCode: 200..<500)
                .responseDecodable(of: StormglassResponse.self, decoder: self.customDecoder) { response in
                    switch response.result {
                    case .success(let response):
                        let weatherModel = response.weather.map {
                            WeatherModel(region, $0)
                        }
                        observer.onNext(weatherModel)
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
    
    func requestWeather(regions: [RegionModel]) -> Observable<[RegionModel:[WeatherModel]]> {
        
        return Observable.create { observer in
            var weatherDictionary: [RegionModel:[WeatherModel]] = [:]
            
            self.parameters["start"] = Date.yesterdayUTC.timeIntervalSince1970.description
            
            regions.forEach { region in
                var parameters = self.parameters
                parameters["lat"] = region.latitude
                parameters["lng"] = region.longitude
                
                AF.request(self.url,
                           method: .get,
                           parameters: self.parameters,
                           encoding: URLEncoding.default,
                           headers: ["Authorization": APIKey().stormGlassAPIKey, "Content-Type":"application/json", "Accept":"application/json"])
                .validate(statusCode: 200..<500)
                .responseDecodable(of: StormglassResponse.self, decoder: self.customDecoder) { response in
                    switch response.result {
                    case .success(let response):
                        let weatherModels = response.weather.map {
                            WeatherModel(region, $0)
                        }
                        weatherDictionary[region] = weatherModels
                    case .failure(let error):
                        observer.onError(error)
                    }
                    observer.onCompleted()
                }
                .resume()
            }
            
            observer.onNext(weatherDictionary)
            
            return Disposables.create {
            }
        }
        
    }
}
