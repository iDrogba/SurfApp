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
        
    let detailWeatherTopStackView: UIStackView = .makeDefaultStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally, spacing: 8, layoutMargin: nil, color: .clear)
    let timeLabelBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.setCornerRadiusShadow(cornerRadius: 8)

        return view
    }()
    let timeLabel: UILabel = {
        let label = UILabel.makeLabel(fontColor: .black, font: .systemFont(ofSize: 13, weight: .bold), textAlignment: .center)
        label.backgroundColor = .clear
        
        return label
    }()
    let surfConditionLabelBackground: UIView = {
        let view = UIView()
        view.backgroundColor = .customBlue2
        view.setCornerRadiusShadow(cornerRadius: 8)

        return view
    }()
    let surfConditionLabel: UILabel = {
        let label = UILabel.makeLabel(fontColor: .white, font: .systemFont(ofSize: 13, weight: .bold), textAlignment: .center)
        label.backgroundColor = .clear

        return label
    }()
    
    let detailWeatherBottomStackView: UIStackView = {
        let stackView = UIStackView.makeDefaultStackView(axis: .horizontal, alignment: .fill, distribution: .fillEqually, spacing: 0, layoutMargin: .defaultInsets, color: .white)
        stackView.setCornerRadiusShadow(cornerRadius: 8)
        
        return stackView
    }()

    let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "wind")
        
        return imageView
    }()
    let temparatureLabel: UILabel = .makeLabel(fontColor: .black, font: .boldSystemFont(ofSize: 18), textAlignment: .left)
    let waveHeightView: DetailCurrentWeatherView = DetailCurrentWeatherView(title: "파고")
    let wavePeriodView: DetailCurrentWeatherView = DetailCurrentWeatherView(title: "너울주기")
    let windSpeedView: DetailCurrentWeatherView = DetailCurrentWeatherView(title: "풍속")
    
    let weekWeatherCollectionView = WeekWeatherCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    let detailWeatherLabel: UILabel = .makeLabel(text: "상세 예보", fontColor: .black, font: .boldSystemFont(ofSize: 17))
    let detailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "questionMark")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    let dayWeatherContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.customLightGray.cgColor
        
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
        
        view.backgroundColor = .defaultBackground
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
                    return UIImage(systemName: "star.fill")?.withTintColor(.customOrange, renderingMode: .alwaysOriginal)
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
                $0.waveHeight.description + "입문자가 즐기기 좋습니다."
            }
            .bind(to: surfConditionLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.currentWeathers
            .map {
                $0.airTemperature.description + "º"
            }
            .bind(to: temparatureLabel.rx.text)
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
        view.addSubview(timeLabelBackground)
        view.addSubview(surfConditionLabelBackground)
        view.addSubview(detailWeatherTopStackView)
        view.addSubview(detailWeatherBottomStackView)
        view.addSubview(weekWeatherCollectionView)
        view.addSubview(detailWeatherLabel)
        view.addSubview(detailImageView)
        view.addSubview(dayWeatherContainerView)
        
        dayWeatherContainerView.addSubview(dayWeatherCollectionView)
        dayWeatherContainerView.addSubview(dayWindGraph)
        dayWeatherContainerView.addSubview(waveBarGraph)

        navigationSeparator.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
        detailWeatherTopStackView.snp.makeConstraints { make in
            make.top.equalTo(navigationSeparator.snp.bottom).offset(26)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.045)
            make.width.equalToSuperview().multipliedBy(0.88)
        }
        
        detailWeatherBottomStackView.snp.makeConstraints { make in
            make.top.equalTo(detailWeatherTopStackView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.09)
            make.width.equalToSuperview().multipliedBy(0.88)
        }
        
        weekWeatherCollectionView.snp.makeConstraints { make in
            make.top.equalTo(detailWeatherBottomStackView.snp.bottom).offset(26)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.12)
            make.width.equalToSuperview().multipliedBy(0.9)
        }
        
        detailWeatherLabel.snp.makeConstraints { make in
            make.top.equalTo(weekWeatherCollectionView.snp.bottom).offset(24)
            make.leading.equalTo(dayWeatherContainerView.snp.leading)
            make.width.equalTo(67)
            make.height.equalTo(20)
        }
        
        detailImageView.snp.makeConstraints { make in
            make.width.equalTo(20)
            make.verticalEdges.equalTo(detailWeatherLabel)
            make.leading.equalTo(detailWeatherLabel.snp.trailing)
        }
        
        dayWeatherContainerView.snp.makeConstraints { make in
            make.top.equalTo(detailWeatherLabel.snp.bottom).offset(8)
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
        detailWeatherTopStackView.addArrangedSubview(timeLabel)
        detailWeatherTopStackView.addArrangedSubview(surfConditionLabel)
        
        detailWeatherBottomStackView.addArrangedSubview(weatherImageView)
        detailWeatherBottomStackView.addArrangedSubview(temparatureLabel)
        detailWeatherBottomStackView.addArrangedSubview(waveHeightView)
        detailWeatherBottomStackView.addArrangedSubview(wavePeriodView)
        detailWeatherBottomStackView.addArrangedSubview(windSpeedView)
        
        surfConditionLabel.setContentHuggingPriority(.init(1), for: .horizontal)
        temparatureLabel.setContentHuggingPriority(.init(1), for: .horizontal)
        
        timeLabelBackground.snp.makeConstraints { make in
            make.edges.equalTo(timeLabel)
        }
        
        surfConditionLabelBackground.snp.makeConstraints { make in
            make.edges.equalTo(surfConditionLabel)
        }
    }
}
