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
        backgroundColor = .blue
        self.register(FavoriteRegionCollectionViewCell.self, forCellWithReuseIdentifier: FavoriteRegionCollectionViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

// MARK: CollectionViewDelegate
extension FavoriteRegionCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width * 0.88
        let cellHeight = (collectionView.bounds.height - 80) / 4.5
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

class FavoriteRegionCollectionViewCell: UICollectionViewCell {
    let rootStackView: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .leading, distribution: .fillProportionally, spacing: 5, color: .clear)
    let localityLabel: UILabel = .makeLabel(color: .black, font: .systemFont(ofSize: 22, weight: .bold))
    let subLocalityLabel: UILabel = .makeLabel(color: .gray, font: .systemFont(ofSize: 13, weight: .bold))
    let waveWindStackView: UIStackView = .makeDefaultStackView(axis: .horizontal, alignment: .fill, distribution: .fill, spacing: 5, color: .white)
    let waveImageView: UIImageView = UIImageView(image: UIImage(named: "wave"))
    let waveLabel: UILabel = .makeLabel(color: .black, font: .systemFont(ofSize: 13, weight: .bold))
    let windImageView: UIImageView = UIImageView(image: UIImage(named: "wind"))
    let windLabel: UILabel = .makeLabel(color: .black, font: .systemFont(ofSize: 13, weight: .bold))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setStackView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setUI() {
        contentView.addSubview(rootStackView)
        
        rootStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.65)
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
