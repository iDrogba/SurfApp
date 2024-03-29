//
//  MapLocationDescriptionView.swift
//  SurfApp
//
//  Created by 김상현 on 2023/05/07.
//

import UIKit
import RxSwift
import RxCocoa

class MapLocationDescriptionView: UIView {
    let mapLocationData: ReplaySubject<FavoriteRegionCellData> = ReplaySubject<FavoriteRegionCellData>.create(bufferSize: 1)
    let disposeBag = DisposeBag()
    
    // 지역 설명 views
    let regionStackView: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .leading, distribution: .fillProportionally, spacing: 5, layoutMargin: nil, color: .clear)
    let regionNameLabel: UILabel = .makeLabel(fontColor: .black, font: .systemFont(ofSize: 22, weight: .bold))
    let localityLabel: UILabel = .makeLabel(fontColor: .customGray, font: .systemFont(ofSize: 13, weight: .bold))
        
    // 서핑 정보 views
    let surfWeatherStackView: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .leading, distribution: .fillProportionally, spacing: 5, layoutMargin: nil, color: .clear)
    let waveWindStackView: UIStackView = .makeDefaultStackView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 5, layoutMargin: nil , color: .white)
    let waveLabel: UILabel = .makeLabel(fontColor: .black, font: .systemFont(ofSize: 13, weight: .bold))
    let windLabel: UILabel = .makeLabel(fontColor: .black, font: .systemFont(ofSize: 13, weight: .bold))
    
    let surfDescriptionColorView: UIView = UIView()
    let surfDescriptionLabel: UILabel = .makeLabel(fontColor: .green, font: .systemFont(ofSize: 13, weight: .bold))
    
    // 기온, 날씨 아이콘 views
    let weatherStackView: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 5, layoutMargin: nil, color: .clear)
    let temparatureLabel: UILabel = .makeLabel(fontColor: .black, font: .systemFont(ofSize: 18, weight: .bold))
    
    let waveImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "wave"))
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    let windImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "wind"))
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    let weatherIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStackView()
        setSubview()
        setData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // cell rounded section
        layer.cornerRadius = 12.0
        layer.borderWidth = 5.0
        layer.borderColor = UIColor.clear.cgColor
        layer.masksToBounds = true
        
        // cell shadow section
        layer.cornerRadius = 12.0
        layer.borderWidth = 5.0
        layer.borderColor = UIColor.clear.cgColor
        backgroundColor = .white
        layer.masksToBounds = true
        
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0.0)
        layer.shadowRadius = 6.0
        layer.shadowOpacity = 0.3
        layer.cornerRadius = 12.0
        layer.masksToBounds = false
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
    }
    
    func setSubview() {
        addSubview(regionStackView)
        addSubview(surfWeatherStackView)
        addSubview(surfDescriptionColorView)
        addSubview(weatherStackView)

        regionStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(20)
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        surfWeatherStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(35)
            make.bottom.equalToSuperview().inset(20)
            make.width.equalTo(regionStackView.snp.width)
            make.height.equalToSuperview().multipliedBy(0.3)
        }
        
        surfDescriptionColorView.snp.makeConstraints { make in
            make.top.equalTo(surfWeatherStackView.snp.top)
            make.trailing.equalTo(surfWeatherStackView.snp.leading).offset(-10)
            make.height.equalTo(surfWeatherStackView.snp.height)
            make.width.equalTo(5)
        }
        
        weatherStackView.snp.makeConstraints { make in
            make.leading.equalTo(surfWeatherStackView.snp.trailing)
            make.trailing.equalToSuperview().inset(10)
            make.top.equalTo(regionStackView.snp.centerY)
            make.bottom.equalTo(surfWeatherStackView.snp.centerY)
        }
        
        weatherIconView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(weatherIconView.snp.width)
        }
    }
    
    func setStackView() {
        regionStackView.addArrangedSubview(regionNameLabel)
        regionStackView.addArrangedSubview(localityLabel)

        surfWeatherStackView.addArrangedSubview(waveWindStackView)
        surfWeatherStackView.addArrangedSubview(surfDescriptionLabel)
        
        waveWindStackView.addArrangedSubview(waveImageView)
        waveWindStackView.addArrangedSubview(waveLabel)
        waveWindStackView.addArrangedSubview(windImageView)
        waveWindStackView.addArrangedSubview(windLabel)
        
        weatherStackView.addArrangedSubview(weatherIconView)
        weatherStackView.addArrangedSubview(temparatureLabel)
    }
    
    private func setData() {
        mapLocationData.map {
            $0.region.regionName
        }
        .bind(to: regionNameLabel.rx.text)
        .disposed(by: disposeBag)
        
        mapLocationData.map {
            $0.region.locality
        }
        .bind(to: localityLabel.rx.text)
        .disposed(by: disposeBag)
        
        mapLocationData.map {
            let minWaveHeight = $0.minMaxWaveHeight.min
            let maxWaveHeight = $0.minMaxWaveHeight.max
            
            return "\(minWaveHeight) - \(maxWaveHeight)m"
        }
        .bind(to: waveLabel.rx.text)
        .disposed(by: disposeBag)
      
        mapLocationData.map {
           "\($0.windSpeed)m/s"
        }
        .bind(to: windLabel.rx.text)
        .disposed(by: disposeBag)
      
        mapLocationData.map {
            "\($0.temparature)°"
        }
        .bind(to: temparatureLabel.rx.text)
        .disposed(by: disposeBag)
        
        mapLocationData.map {
            $0.surfCondition.0
        }
        .bind(to: surfDescriptionLabel.rx.text)
        .disposed(by: disposeBag)
        
        mapLocationData.map {
            $0.surfCondition.1
        }
        .bind(to: surfDescriptionLabel.rx.textColor)
        .disposed(by: disposeBag)
        
        mapLocationData.map {
            $0.surfCondition.1
        }
        .bind(to: surfDescriptionColorView.rx.backgroundColor)
        .disposed(by: disposeBag)
        
        mapLocationData.map {
            UIImage(named: $0.weatherCondition)
        }
        .bind(to: weatherIconView.rx.image)
        .disposed(by: disposeBag)
        
        surfDescriptionColorView.backgroundColor = .customGreen
    }
}
