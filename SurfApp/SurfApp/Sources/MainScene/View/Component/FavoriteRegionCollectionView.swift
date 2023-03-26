//
//  FavoriteRegionCollectionView.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/04.
//

import UIKit

class FavoriteRegionCollectionView: UICollectionView {

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        if let layout = layout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 0
        }
        
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        backgroundColor = .clear
        layer.masksToBounds = false
        showsVerticalScrollIndicator = false
        
        self.register(FavoriteRegionCollectionViewCell.self, forCellWithReuseIdentifier: FavoriteRegionCollectionViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

// MARK: CollectionViewDelegate
extension FavoriteRegionCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width
        let cellHeight = (collectionView.bounds.height - 60) / 4
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

class FavoriteRegionCollectionViewCell: UICollectionViewCell {
    // 지역 설명 views
    let regionStackView: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .leading, distribution: .fillProportionally, spacing: 5, layoutMargin: nil, color: .clear)
    let regionNameLabel: UILabel = .makeLabel(color: .black, font: .systemFont(ofSize: 22, weight: .bold))
    let localityLabel: UILabel = .makeLabel(color: .customGray, font: .systemFont(ofSize: 13, weight: .bold))
        
    // 서핑 정보 views
    let surfWeatherStackView: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .leading, distribution: .fillProportionally, spacing: 5, layoutMargin: nil, color: .clear)
    let waveWindStackView: UIStackView = .makeDefaultStackView(axis: .horizontal, alignment: .center, distribution: .fill, spacing: 5, layoutMargin: nil , color: .white)
    let waveLabel: UILabel = .makeLabel(color: .black, font: .systemFont(ofSize: 13, weight: .bold))
    let windLabel: UILabel = .makeLabel(color: .black, font: .systemFont(ofSize: 13, weight: .bold))
    
    let surfDescriptionColorView: UIView = UIView()
    let surfDescriptionLabel: UILabel = .makeLabel(color: .green, font: .systemFont(ofSize: 13, weight: .bold))
    
    // 기온, 날씨 아이콘 views
    let weatherStackView: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 5, layoutMargin: nil, color: .clear)
    let temparatureLabel: UILabel = .makeLabel(color: .black, font: .systemFont(ofSize: 18, weight: .bold))
    
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
        let imageView = UIImageView(image: UIImage(named: "wave"))
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setStackView()
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // cell rounded section
        self.layer.cornerRadius = 12.0
        self.layer.borderWidth = 5.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
        
        // cell shadow section
        self.contentView.layer.cornerRadius = 12.0
        self.contentView.layer.borderWidth = 5.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.backgroundColor = .white
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
        self.layer.shadowRadius = 6.0
        self.layer.shadowOpacity = 0.6
        self.layer.cornerRadius = 12.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
    }
    
    func setUI() {
        contentView.addSubview(regionStackView)
        contentView.addSubview(surfWeatherStackView)
        contentView.addSubview(surfDescriptionColorView)
        contentView.addSubview(weatherStackView)

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
    
    func setData(weather: FavoriteRegionCellData) {
        let region = weather.region
        regionNameLabel.text = region.regionName
        localityLabel.text = region.locality
        
        let minWaveHeight = weather.minMaxWaveHeight.min
        let maxWaveHeight = weather.minMaxWaveHeight.max
        waveLabel.text = "\(minWaveHeight) - \(maxWaveHeight)m"
        windLabel.text = "\(weather.windSpeed)m/s"
        
        surfDescriptionLabel.text = "입문자가 즐기기 좋습니다."
        surfDescriptionLabel.textColor = .customGreen
        surfDescriptionColorView.backgroundColor = .customGreen
        
        temparatureLabel.text = "\(weather.temparature)°"
    }
}
