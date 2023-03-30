//
//  DetailWeatherViewController.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/04.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import SnapKit

class DetailWeatherViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel: DetailWeatherViewModel
    
//    var waveBarGraph = BarGraph()
    let localityStackVeiw: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .center, distribution: .fillProportionally, spacing: 0, layoutMargin: nil, color: .clear)
    let localityLabel: UILabel = .makeLabel(color: .black, font: .systemFont(ofSize: 22, weight: .bold))
    let subLocalityLabel: UILabel = .makeLabel(color: .customGray, font: .systemFont(ofSize: 15, weight: .bold))
    
    let detailWeatherBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .customLightGray
        view.layer.cornerRadius = 12
        
        return view
    }()
    let detailWeatherStackVeiw: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .fill, distribution: .fillProportionally, spacing: 0, layoutMargin: nil, color: .clear)
    let timeLabel: UILabel = {
        let label = UILabel.makeLabel(color: .black, font: .systemFont(ofSize: 15, weight: .bold))
        label.textAlignment = .center
        
        return label
    }()
    let detailWeatherTopStackView: UIStackView = .makeDefaultStackView(axis: .horizontal, alignment: .center, distribution: .fillEqually, spacing: 0, layoutMargin: nil, color: .clear)
    let temparatureView: DetailCurrentWeatherView = DetailCurrentWeatherView(iconImage: UIImage(named: "wind")!, title: "온도")
    let waveHeightView: DetailCurrentWeatherView = DetailCurrentWeatherView(iconImage: UIImage(named: "wind")!, title: "파고")
    let detailWeatherBottomStackView: UIStackView = .makeDefaultStackView(axis: .horizontal, alignment: .center, distribution: .fillEqually, spacing: 0, layoutMargin: nil, color: .clear)
    let wavePeriodView: DetailCurrentWeatherView = DetailCurrentWeatherView(iconImage: UIImage(named: "wind")!, title: "너울주기")
    let windSpeedView: DetailCurrentWeatherView = DetailCurrentWeatherView(iconImage: UIImage(named: "wind")!, title: "풍속")
    let surfConditionLabel: UILabel = {
        let label = UILabel.makeLabel(text: "입문자가 즐기기 좋습니다.", color: .customGreen, font: .systemFont(ofSize: 15, weight: .bold))
        label.textAlignment = .center
        
        return label
    }()

    init(region: RegionModel) {
        viewModel = DetailWeatherViewModel(region: region)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        let defaultRegionPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.5, longitude: 128))
        viewModel = DetailWeatherViewModel(region: RegionModel(placeMark: defaultRegionPlaceMark))
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.addSubview(waveBarGraph)
//        waveBarGraph.snp.makeConstraints { make in
//            make.horizontalEdges.equalToSuperview()
//            make.top.equalToSuperview()
//            make.height.equalToSuperview().multipliedBy(1)
//        }
//
//        viewModel.waveGraphModels.asObservable()
//            .bind(to: waveBarGraph.rx.items(cellIdentifier: BarGraphCell.identifier, cellType: BarGraphCell.self)) { item, element, cell in
//                cell.setUI(barGraphModel: element)
//            }
//            .disposed(by: disposeBag)
        
        view.backgroundColor = .white
        setRxData()
        setUI()
        setStackView()
    }
    
    private func setRxData() {
        viewModel.currentWeathers
            .map {
                $0.date.convertToKoreanDate()
            }
            .bind(to: timeLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentWeathers
            .map {
                $0.regionModel.regionName
            }
            .bind(to: localityLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentWeathers
            .map {
                "\($0.regionModel.locality) \($0.regionModel.subLocality)"
            }
            .bind(to: subLocalityLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentWeathers
            .map {
                $0.airTemperature.description + "º"
            }
            .bind(to: temparatureView.dataLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentWeathers
            .map {
                $0.waveHeight.description + "m"
            }
            .bind(to: waveHeightView.dataLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentWeathers
            .map {
                $0.wavePeriod.description + "'s"
            }
            .bind(to: wavePeriodView.dataLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentWeathers
            .map {
                $0.windSpeed.description + "km/h"
            }
            .bind(to: windSpeedView.dataLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func setUI() {
        view.addSubview(localityStackVeiw)
//        view.addSubview(detailWeatherBackgroundView)
        view.addSubview(detailWeatherStackVeiw)
        
        localityStackVeiw.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalToSuperview().multipliedBy(0.1)
        }
        
//        detailWeatherBackgroundView.snp.makeConstraints { make in
//            make.top.equalTo(localityStackVeiw.snp.bottom)
//            make.centerX.equalToSuperview()
//            make.height.equalToSuperview().multipliedBy(0.25)
//            make.width.equalToSuperview().multipliedBy(0.88)
//        }
//
        detailWeatherStackVeiw.snp.makeConstraints { make in
            make.top.equalTo(localityStackVeiw.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
            make.width.equalToSuperview().multipliedBy(0.7)
        }
    }
    
    private func setStackView() {
        localityStackVeiw.addArrangedSubview(localityLabel)
        localityStackVeiw.addArrangedSubview(subLocalityLabel)
        
        detailWeatherStackVeiw.addArrangedSubview(timeLabel)
        detailWeatherStackVeiw.addArrangedSubview(detailWeatherTopStackView)
        detailWeatherStackVeiw.addArrangedSubview(detailWeatherBottomStackView)
        detailWeatherStackVeiw.addArrangedSubview(surfConditionLabel)
        
        detailWeatherTopStackView.addArrangedSubview(temparatureView)
        detailWeatherTopStackView.addArrangedSubview(waveHeightView)
        detailWeatherBottomStackView.addArrangedSubview(wavePeriodView)
        detailWeatherBottomStackView.addArrangedSubview(windSpeedView)
    }

}
