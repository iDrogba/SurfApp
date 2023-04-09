//
//  dayWeatherCollectionView.swift
//  SurfApp
//
//  Created by 김상현 on 2023/04/02.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class DayWeatherCollectionView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        
        if let layout = layout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
        }
       
        super.init(frame: frame, collectionViewLayout: layout)
        
        delegate = self
        backgroundColor = .customLightGray
        showsVerticalScrollIndicator = false
        register(DayWeatherCollectionViewCell.self, forCellWithReuseIdentifier: DayWeatherCollectionViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: CollectionViewDelegate
extension DayWeatherCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 8
        let cellHeight = collectionView.bounds.height
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

class DayWeatherCollectionViewCell: UICollectionViewCell {
    let disposeBag = DisposeBag()
    let dayWeatherCellData = PublishSubject<DayWeatherCellData>()
    
    let stackView: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .center, distribution: .fill, layoutMargin: nil)
    let dateLabel: UILabel = .makeLabel(fontColor: .black, font: .systemFont(ofSize: 12, weight: .bold))
    let weatherImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "wind")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    let temparatureLabel: UILabel = .makeLabel(fontColor: .black, font: .systemFont(ofSize: 12, weight: .bold))

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setSubview()
        setData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubview() {
        contentView.addSubview(stackView)
        
        stackView.addArrangedSubview(dateLabel)
        stackView.addArrangedSubview(weatherImageView)
        stackView.addArrangedSubview(temparatureLabel)
        
        weatherImageView.setContentHuggingPriority(.init(0), for: .vertical)
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
        }
    }
    
    func setData() {
        dayWeatherCellData.map {
            $0.date
        }
        .bind(to: dateLabel.rx.text)
        .disposed(by: disposeBag)
        
        dayWeatherCellData.map {
            UIImage(named: $0.weather)
        }
        .bind(to: weatherImageView.rx.image)
        .disposed(by: disposeBag)
        
        dayWeatherCellData.map {
            $0.temparature
        }
        .bind(to: temparatureLabel.rx.text)
        .disposed(by: disposeBag)
    }
    
}
