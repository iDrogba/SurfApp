//
//  BarGraph.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/21.
//

import UIKit
import SnapKit
import RxSwift

class BarGraph: UICollectionView {
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        super.init(frame: CGRect(origin: .zero, size: .zero), collectionViewLayout: layout)
        
        delegate = self
        self.register(BarGraphCell.self, forCellWithReuseIdentifier: BarGraphCell.identifier)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: CollectionViewDelegate
extension BarGraph: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.bounds.width / 8
        let cellHeight = collectionView.bounds.height
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

class BarGraphCell: UICollectionViewCell {
    let disposeBag = DisposeBag()
    let dayWaveGraphDatas = PublishSubject<BarGraphModel>()
    
    let bar: UIView = {
        let bar = UIView()
        
        return bar
    }()
    
    let separator: UIView = {
        let view = UIView()
        view.backgroundColor = .customChartGray
        
        return view
    }()
    
    let topImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    let middleLabel: UILabel = .makeLabel(color: .black, font: .boldSystemFont(ofSize: 11), textAlignment: .center)
    let bottomLabel: UILabel = .makeLabel(color: .black, font: .boldSystemFont(ofSize: 11), textAlignment: .center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setSubview()
        barLayout()
        setRxData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func barLayout() {
        bar.clipsToBounds = true
        bar.layer.cornerRadius = 4
        bar.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner)
    }
    
    private func setSubview() {
        contentView.addSubview(bar)
        contentView.addSubview(separator)
        contentView.addSubview(middleLabel)
        contentView.addSubview(bottomLabel)
        contentView.addSubview(topImageView)
        
        bottomLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.15)
        }
        
        separator.snp.makeConstraints { make in
            make.bottom.equalTo(bottomLabel.snp.top)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
        middleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(separator.snp.bottom)
            make.horizontalEdges.equalTo(bar.snp.horizontalEdges)
            make.height.equalToSuperview().multipliedBy(0.15)
        }
        
        topImageView.snp.makeConstraints { make in
            make.bottom.equalTo(bar.snp.top).offset(-5)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.1)
            make.width.equalTo(topImageView.snp.height)
        }
    }
        
    private func setRxData() {
        
        dayWaveGraphDatas
            .subscribe { barGraphModel in
                if let barGraphModel = barGraphModel.element {
                    self.bar.backgroundColor = barGraphModel.color
                    self.bottomLabel.text = barGraphModel.value1
                    self.middleLabel.text = barGraphModel.value2
                    self.topImageView.image = barGraphModel.icon
                    
                    self.bar.snp.removeConstraints()
                    
                    let topPoint = 0.55 * barGraphModel.topPoint + 0.15

                    self.bar.snp.makeConstraints { make in
                        make.centerX.equalToSuperview()
                        make.width.equalToSuperview().multipliedBy(barGraphModel.width)
                        make.height.equalToSuperview().multipliedBy(topPoint)
                        make.bottom.equalTo(self.separator.snp.top)
                    }
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    
}
