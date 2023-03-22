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
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 0
        }
        
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        backgroundColor = .clear
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
    let rootStackView: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .leading, distribution: .fillProportionally, spacing: 5, layoutMargin: nil, color: .clear)
    let localityLabel: UILabel = .makeLabel(color: .black, font: .systemFont(ofSize: 22, weight: .bold))
    let subLocalityLabel: UILabel = .makeLabel(color: .gray, font: .systemFont(ofSize: 13, weight: .bold))
    let waveWindStackView: UIStackView = .makeDefaultStackView(axis: .horizontal, alignment: .leading, distribution: .fill, spacing: 5, layoutMargin: nil , color: .white)
    let waveLabel: UILabel = .makeLabel(color: .black, font: .systemFont(ofSize: 13, weight: .bold))
    let windLabel: UILabel = .makeLabel(color: .black, font: .systemFont(ofSize: 13, weight: .bold))
    
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

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setStackView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUI() {
        DispatchQueue.main.async { [weak self] in
            self?.backgroundColor = .white
            self?.layer.cornerRadius = 18
        }
        
        contentView.addSubview(rootStackView)
        
        rootStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.8)
        }
    }
    
    func setStackView() {
        rootStackView.addArrangedSubview(localityLabel)
        rootStackView.addArrangedSubview(subLocalityLabel)
        rootStackView.addArrangedSubview(waveWindStackView)
        
        waveWindStackView.addArrangedSubview(waveImageView)
        waveWindStackView.addArrangedSubview(waveLabel)
        waveWindStackView.addArrangedSubview(windImageView)
        waveWindStackView.addArrangedSubview(windLabel)
    }
    
    func setData(weather: WeatherModel) {
        let region = weather.regionModel
        localityLabel.text = region.locality
        subLocalityLabel.text = region.subLocality
        
        waveLabel.text = weather.waveHeight.description
        windLabel.text = weather.windSpeed.description
    }
}
