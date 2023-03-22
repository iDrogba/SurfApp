//
//  DetailWeatherViewModel.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/21.
//

import Foundation
import RxSwift

class DetailWeatherViewModel {
    let disposeBag = DisposeBag()
    let stormglassResponse = PublishSubject<[WeatherModel]>()
    let todayWeathers = PublishSubject<[WeatherModel]>()
    let today3HourWeathers = PublishSubject<[WeatherModel]>()
    let waveGraphModels = PublishSubject<[BarGraphModel]>()
    
    init(region: RegionModel) {
//        SavedRegionManager.shared.saveRegion(region)

        StormglassNetworking.shared.requestWeather(region: region)
            .bind(to: self.stormglassResponse)
            .disposed(by: disposeBag)
        
        stormglassResponse
            .map{
                $0.getTodayWeather()
            }
            .bind(to: todayWeathers)
            .disposed(by: disposeBag)
        
        stormglassResponse
            .map { weathers in
                weathers.getToday3HourWeather()
            }
            .bind(to: today3HourWeathers)
            .disposed(by: disposeBag)
        
        today3HourWeathers
            .map { weathers in
                var maxValue = weathers.first?.waveHeight ?? 0
                var minValue = weathers.first?.waveHeight ?? 0
                
                weathers.forEach {
                    if $0.waveHeight > maxValue {
                        maxValue = $0.waveHeight
                    }
                    if $0.waveHeight < minValue {
                        minValue = $0.waveHeight
                    }
                }
                
                return (maxValue, minValue, weathers)
            }
            .map { (maxValue, minValue, weathers) in
                weathers.map {
                    let topPoint = $0.waveHeight / maxValue
                    let bottomPoint = ($0.waveHeight - minValue) / maxValue
                    
                    return BarGraphModel(color: .black, topPoint: topPoint, bottomPoint: bottomPoint, width: 0.8)
                }
            }
            .bind(to: waveGraphModels)
            .disposed(by: disposeBag)
            
    }
    
    
    
}
