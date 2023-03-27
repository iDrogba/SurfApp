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
    let weathers = PublishSubject<[WeatherModel]>()
    let todayWeathers = PublishSubject<[WeatherModel]>()
    let today3HourWeathers = PublishSubject<[WeatherModel]>()
    let waveGraphModels = ReplaySubject<[BarGraphModel]>.create(bufferSize: 1)

    init(region: RegionModel) {
        //        SavedRegionManager.shared.saveRegion(region)
        setTodayWeathers()
        set3HourWeathers()
        
        if let weathers = WeatherModelManager.shared.weatherModels[region] {
            Observable.create { observer in
                observer.onNext(weathers)
                return Disposables.create { }
            }
            .bind(to: self.weathers)
            .disposed(by: disposeBag)
        } else {
            StormglassNetworking.shared.requestWeather(region: region)
                .bind(to: self.weathers)
                .disposed(by: disposeBag)
        }
    }
    
    private func setTodayWeathers() {
        weathers
            .map{
                $0.getTodayWeather()
            }
            .bind(to: todayWeathers)
            .disposed(by: disposeBag)
    }
    
    private func set3HourWeathers() {
        self.weathers
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
            .debug()
            .bind(to: waveGraphModels)
            .disposed(by: disposeBag)
    }
}
