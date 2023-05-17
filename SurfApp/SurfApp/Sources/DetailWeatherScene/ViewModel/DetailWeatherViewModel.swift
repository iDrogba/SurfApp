//
//  DetailWeatherViewModel.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/21.
//

import UIKit
import RxSwift
import Charts

class DetailWeatherViewModel {
    let disposeBag = DisposeBag()
    let selectedDateIndex = BehaviorSubject(value: 0)

    let region: RegionModel
    let isFavoriteRegion = ReplaySubject<Bool>.create(bufferSize: 1)
    let weathers = PublishSubject<[WeatherModel]>()
    let todayWeathers = PublishSubject<[WeatherModel]>()
    let currentWeathers = ReplaySubject<WeatherModel>.create(bufferSize: 1)

    let threeHourEachDayWeathers = PublishSubject<[[WeatherModel]]>()
    let currentWeekMinMaxWaveHeight = ReplaySubject<(min:Double, max:Double)>.create(bufferSize: 1)
    let selectedDayDatas = PublishSubject<[WeatherModel]>()
    let weekWeatherCellDatas = ReplaySubject<[WeekWeatherCellData]>.create(bufferSize: 1)
    let dayWeatherCellDatas = ReplaySubject<[DayWeatherCellData]>.create(bufferSize: 1)
    let dayWindGraphDatas = ReplaySubject<LineChartData>.create(bufferSize: 1)
    let dayWaveGraphModels = ReplaySubject<[BarGraphModel]>.create(bufferSize: 1)
    
    init(region: RegionModel) {
        self.region = region
        setIsFavoriteRegion()
        setTodayWeathers()
        setCurrentWeathers()
        setThreeHourEachDayWeathers()
        setMinMaxWaveHeight()
        setWeekWeatherModels()
        setSelectedDayDatas()
        setDayWindGraphDatas()
        setDayWaveGraphDatas()
        
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
    
    private func setIsFavoriteRegion() {
        SavedRegionManager.shared.savedRegionSubject
            .map {
                $0.contains(self.region)
            }
            .bind(to: isFavoriteRegion)
            .disposed(by: disposeBag)
    }
    
    private func setTodayWeathers() {
        weathers
            .map{
                $0.getTodayWeather()
            }
            .bind(to: todayWeathers)
            .disposed(by: disposeBag)
    }
    
    private func setCurrentWeathers() {
        self.weathers
            .map { weathers in
                weathers.getCurrentWeather()!
            }
            .bind(to: currentWeathers)
            .disposed(by: disposeBag)
    }
    
    private func setThreeHourEachDayWeathers() {
        weathers
            .map { weathers in
                let sortedWeathers = weathers.filter {
                    $0.isDateMultiplyOf(hour: 3)
                }
                return sortedWeathers.sliceBySameDate()
            }
            .bind(to: threeHourEachDayWeathers)
            .disposed(by: disposeBag)
    }
    
    private func setWeekWeatherModels() {
        threeHourEachDayWeathers
            .map { weathers in
                let weathers = weathers.map {
                    WeekWeatherCellData(weathers: $0)
                }
                return Array(weathers[0...6])
            }
            .bind(to: weekWeatherCellDatas)
            .disposed(by: disposeBag)
    }
    
    private func setSelectedDayDatas() {
        Observable
            .combineLatest(threeHourEachDayWeathers, selectedDateIndex)
            .map { $0[$1] }
            .bind(to: selectedDayDatas)
            .disposed(by: disposeBag)
        
        selectedDayDatas
            .map { weathers in
                weathers.map {
                    let date = $0.date.time()
                    let weather = $0.weatherCondition
                    let temparature = $0.airTemperature.description + "º"
                    
                    return DayWeatherCellData(date: date, weather: weather, temparature: temparature)
                }
            }
            .bind(to: dayWeatherCellDatas)
            .disposed(by: disposeBag)
    }
    
    private func setDayWindGraphDatas() {
        selectedDayDatas
            .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .default))
            .map{ $0.enumerated() }
            .map { weathers in
                let entries = weathers.map {
                    let windSpeed = $1.windSpeed
                    let windDirection = $1.windDirection
                    
                    let largeConfig = NSUIImage.SymbolConfiguration(pointSize: 100, weight: .bold, scale: .large)
                    let rotatedSize = CGSize(width: 200, height: 200)
                    var icon = NSUIImage(systemName: "arrow.down", withConfiguration: largeConfig)?.rotate(degrees: windDirection, rotatedSize: rotatedSize)
                    icon = icon?.imageWith(newSize: CGSize(width: 14, height: 14))

                    let chartDataEntry = ChartDataEntry(x: Double($0), y: windSpeed, icon: icon, data: windSpeed)

                    return chartDataEntry
                }
                
                let lineChartDataSet = LineChartDataSet(entries: entries)
                // gradient fill
                let gradientColors = [UIColor.customNavy.cgColor, UIColor.white.cgColor] as CFArray
                let colorLocations:[CGFloat] = [1.0, 0.0]
                let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations)
                lineChartDataSet.fill = LinearGradientFill(gradient: gradient!, angle: 90)
                
                lineChartDataSet.drawFilledEnabled = true
                lineChartDataSet.drawIconsEnabled = true
                lineChartDataSet.colors = [.customNavy]
                lineChartDataSet.drawCirclesEnabled = false
                lineChartDataSet.lineWidth = 1
                lineChartDataSet.valueFont = .boldSystemFont(ofSize: 10)
                
                let lineChartData = LineChartData(dataSet: lineChartDataSet)
                
                return lineChartData
            }
            .bind(to: dayWindGraphDatas)
            .disposed(by: disposeBag)
    }
    
    private func setMinMaxWaveHeight() {
        self.weathers
            .map { $0.getWeatherAfter(day: Date()) }
            .map { $0.minMaxWaveHeight() }
            .bind(to: self.currentWeekMinMaxWaveHeight)
            .disposed(by: disposeBag)
    }
    
    private func setDayWaveGraphDatas() {
        
        Observable.combineLatest(selectedDayDatas, currentWeekMinMaxWaveHeight)
            .map { weathers, minMaxWaveHeight in
                let barGraphModel = weathers.map {
                    let waveHeight = $0.waveHeight
                    let wavePeriod = $0.wavePeriod
                    let topPoint = (waveHeight - minMaxWaveHeight.min) / (minMaxWaveHeight.max - minMaxWaveHeight.min)

                    let largeConfig = UIImage.SymbolConfiguration(pointSize: 100, weight: .bold, scale: .large)
                    var icon = UIImage()
                    if let image = UIImage(systemName: "arrow.down", withConfiguration: largeConfig) {
                        let rotatedSize = CGSize(width: 200, height: 200)
                        icon = image.rotate(degrees: $0.waveDirection, rotatedSize: rotatedSize)
                    }
                    icon = icon.imageWith(newSize: CGSize(width: 14, height: 14))
                    let gradientColor = (UIColor.customLightNavy, UIColor.white)
                    
                    return BarGraphModel(gradientColor: gradientColor, topPoint: topPoint, bottomPoint: 0, width: 0.8, value1: wavePeriod.description + "'", value2: waveHeight.description , icon: icon)
                }
                
                return barGraphModel
            }
            .bind(to: dayWaveGraphModels)
            .disposed(by: disposeBag)
        
    }
    
    func toggleFavoriteRegion() {
        isFavoriteRegion
            .take(1)
            .subscribe {
                if $0 {
                    SavedRegionManager.shared.removeSavedRegion(self.region)
                } else {
                    SavedRegionManager.shared.saveRegion(self.region)
                }
            }
            .disposed(by: disposeBag)
        
    }
}
