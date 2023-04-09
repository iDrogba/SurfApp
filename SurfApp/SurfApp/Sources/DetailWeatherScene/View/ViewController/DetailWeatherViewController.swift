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
import Charts

class DetailWeatherViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel: DetailWeatherViewModel
    
    let navigationSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .customChartGray
        
        return view
    }()
    
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
    let weekWeatherCollectionView = WeekWeatherCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let dayWeatherContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .customLightGray
        
        return view
    }()
    let dayWeatherCollectionView = DayWeatherCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    let dayWindGraph = DayWindGraph(frame: .zero)
    var waveBarGraph = BarGraph()

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
        
        view.backgroundColor = .white
        setNavigationBar()
        setRxData()
        setUI()
        setStackView()
        setCollectionView()
        setGraph()
    }
    
    private func setNavigationBar() {
        let chevronImage = UIImage(systemName: "chevron.left")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let backButtonItem = UIBarButtonItem(image: chevronImage, style: .plain, target: self, action: #selector(onTapNavigationBackButton))
        
        let starImage = UIImage(systemName: "star.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let starButtonItem = UIBarButtonItem(image: starImage, style: .plain, target: self, action: #selector(onTapStarButton))
        
        navigationItem.setLeftBarButtonItems([backButtonItem], animated: false)
        navigationItem.setRightBarButtonItems([starButtonItem], animated: false)
        navigationItem.title = viewModel.region.regionName
        
        viewModel.isFavoriteRegion
            .map {
                if $0 {
                    return UIImage(systemName: "star.fill")?.withTintColor(.yellow, renderingMode: .alwaysOriginal)
                } else {
                    return UIImage(systemName: "star.fill")?.withTintColor(.black, renderingMode: .alwaysOriginal)
                }
            }
            .bind(to: navigationItem.rightBarButtonItem!.rx.image)
            .disposed(by: disposeBag)
    }
    
    @objc
    private func onTapNavigationBackButton() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc
    private func onTapStarButton() {
        viewModel.toggleFavoriteRegion()
    }
    
    private func setGraph() {
        viewModel.dayWindGraphDatas
            .bind(to: dayWindGraph.dayWindGraphDatas)
            .disposed(by: disposeBag)
        
        viewModel.dayWaveGraphModels.asObservable()
            .bind(to: waveBarGraph.rx.items(cellIdentifier: BarGraphCell.identifier, cellType: BarGraphCell.self)) { item, element, cell in
                
                self.viewModel.dayWaveGraphModels
                    .map { $0[item] }
                    .bind(to: cell.dayWaveGraphDatas)
                    .disposed(by: cell.disposeBag)
                
            }
            .disposed(by: disposeBag)
    }
    
    private func setCollectionView() {
        viewModel.weekWeatherCellDatas
            .bind(to: weekWeatherCollectionView.rx.items(cellIdentifier: WeekWeatherCollectionViewCell.identifier, cellType: WeekWeatherCollectionViewCell.self)) { item, element, cell in
                cell.cellItem = item
                cell.setUI(weekWeatherModel: element)
                
                self.viewModel.selectedDateIndex
                    .bind(to: cell.selectedDateIndex)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        weekWeatherCollectionView.rx.itemSelected
            .subscribe { indexPath in
                if let item = indexPath.element?.item {
                    self.viewModel.selectedDateIndex.onNext(item)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.dayWeatherCellDatas
            .bind(to: dayWeatherCollectionView.rx.items(cellIdentifier: DayWeatherCollectionViewCell.identifier, cellType: DayWeatherCollectionViewCell.self)) { item, element, cell in

                self.viewModel.dayWeatherCellDatas
                    .map {
                        $0[item]
                    }
                    .bind(to: cell.dayWeatherCellData)
                    .disposed(by: cell.disposeBag)
                
            }
            .disposed(by: disposeBag)
    }
    
    private func setRxData() {
        viewModel.currentWeathers
            .map {
                $0.date.dateFormatA()
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
        view.addSubview(navigationSeparator)
        view.addSubview(localityStackVeiw)
        view.addSubview(detailWeatherBackgroundView)
        view.addSubview(detailWeatherStackVeiw)
        view.addSubview(weekWeatherCollectionView)
        view.addSubview(dayWeatherContainerView)
        
        dayWeatherContainerView.addSubview(dayWeatherCollectionView)
        dayWeatherContainerView.addSubview(dayWindGraph)
        dayWeatherContainerView.addSubview(waveBarGraph)

        navigationSeparator.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
        localityStackVeiw.snp.makeConstraints { make in
            make.top.equalTo(navigationSeparator.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalToSuperview().multipliedBy(0.1)
        }
        
        detailWeatherBackgroundView.snp.makeConstraints { make in
            make.top.equalTo(localityStackVeiw.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
            make.width.equalToSuperview().multipliedBy(0.9)
        }

        detailWeatherStackVeiw.snp.makeConstraints { make in
            make.top.equalTo(localityStackVeiw.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.25)
            make.width.equalToSuperview().multipliedBy(0.7)
        }
        
        weekWeatherCollectionView.snp.makeConstraints { make in
            make.top.equalTo(detailWeatherStackVeiw.snp.bottom).offset(26)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.12)
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        dayWeatherContainerView.snp.makeConstraints { make in
            make.top.equalTo(weekWeatherCollectionView.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        dayWeatherCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
            make.width.equalToSuperview()
        }
        
        dayWindGraph.snp.makeConstraints { make in
            make.top.equalTo(dayWeatherCollectionView.snp.bottom)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.3)
            make.width.equalToSuperview().multipliedBy(0.93)
        }
        
        waveBarGraph.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalTo(dayWindGraph.snp.bottom)
            make.bottom.equalToSuperview()
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
