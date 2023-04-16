//
//  WeekWeatherCollectionView.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/30.
//

import UIKit
import RxSwift
import SnapKit

class WeekWeatherCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        
        if let layout = layout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
       
        super.init(frame: frame, collectionViewLayout: layout)
        
        backgroundColor = .clear
        delegate = self
        self.showsVerticalScrollIndicator = false
        self.register(WeekWeatherCollectionViewCell.self, forCellWithReuseIdentifier: WeekWeatherCollectionViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: CollectionViewDelegate
extension WeekWeatherCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 7
        let cellHeight = collectionView.bounds.height
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

class WeekWeatherCollectionViewCell: UICollectionViewCell {
    var cellItem: Int = 0
    let disposeBag = DisposeBag()
    let selectedDateIndex = PublishSubject<Int>()
    
    let stackView: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .center, distribution: .fill, layoutMargin: nil, color: .clear)
    let dayLabel: UILabel = .makeLabel(fontColor: .customGray, font: .systemFont(ofSize: 12, weight: .bold))
    let dateLabel: UILabel = .makeLabel(fontColor: .customGray, font: .systemFont(ofSize: 12, weight: .bold))
    let weatherImageContainerView: UIView = {
        let view = UIView()
        return view
    }()
    let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "wind")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    let minMaxTemparatureLabel: UILabel = .makeLabel(fontColor: .black, font: .systemFont(ofSize: 12, weight: .bold))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubview()
        setBackgroundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.borderColor = UIColor.customSkyBlue.cgColor
        clipsToBounds = true
        layer.cornerRadius = 8
    }
    
    private func setSubview() {
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(dayLabel)
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(weatherImageContainerView)
        stackView.addArrangedSubview(minMaxTemparatureLabel)
        
        weatherImageView.setContentHuggingPriority(.init(0), for: .vertical)
        
        weatherImageContainerView.addSubview(weatherImageView)
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
        }
        
        weatherImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.7)
            make.height.equalToSuperview().multipliedBy(0.7)
        }
    }
    
    private func setBackgroundColor() {
        selectedDateIndex
            .subscribe { index in
                if index == self.cellItem {
                    self.backgroundColor = .customSkyBlue.withAlphaComponent(0.1)
                    self.layer.borderWidth = 1
                } else {
                    self.backgroundColor = .clear
                    self.layer.borderWidth = 0
                }
            }
            .disposed(by: disposeBag)
    }
    
    func setUI(weekWeatherModel: WeekWeatherCellData) {
        dayLabel.text = weekWeatherModel.day
        dateLabel.text = weekWeatherModel.date
        weatherImageView.image = UIImage(named: weekWeatherModel.weather)
        minMaxTemparatureLabel.text = weekWeatherModel.minMaxTemparature
        
        if weekWeatherModel.isToday {
            dayLabel.textColor = .black
            dateLabel.textColor = .black
        }
        
        if weekWeatherModel.isWeekEnd {
            dayLabel.textColor = .red
            dateLabel.textColor = .red
        }
    }
    
}
