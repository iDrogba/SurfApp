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
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    let valueLabel: UILabel = .makeLabel(fontColor: .customNavy, font: .boldSystemFont(ofSize: 11), textAlignment: .center)
    let bottomLabel: UILabel = .makeLabel(fontColor: .black, font: .boldSystemFont(ofSize: 11), textAlignment: .center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setSubview()
        setBarUI()
        setRxData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBarUI() {
        let topBorder = CALayer()
        let borderWidth = 1.0
        let borderFrame = CGRect(origin: .zero, size: CGSize(width: self.bar.bounds.width, height: borderWidth))
        topBorder.frame = borderFrame
        topBorder.backgroundColor = UIColor.customNavy.cgColor
        self.bar.layer.addSublayer(topBorder)
    }
    
    private func setSubview() {
        contentView.addSubview(bar)
        contentView.addSubview(separator)
        contentView.addSubview(bottomLabel)
        contentView.addSubview(imageView)
        contentView.addSubview(valueLabel)

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
        
        valueLabel.snp.makeConstraints { make in
            make.bottom.equalTo(bar.snp.top)
            make.horizontalEdges.equalTo(bar.snp.horizontalEdges)
            make.height.equalToSuperview().multipliedBy(0.15)
        }
        
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(separator.snp.bottom).offset(-5)
            make.height.equalToSuperview().multipliedBy(0.1)
            make.width.equalTo(imageView.snp.height)
        }
    }
        
    private func setRxData() {
        
        dayWaveGraphDatas
            .subscribe { barGraphModel in
                if let barGraphModel = barGraphModel.element {
                    self.bottomLabel.text = barGraphModel.value1
                    self.valueLabel.text = barGraphModel.value2
                    self.imageView.image = barGraphModel.icon
                    
                    self.bar.snp.removeConstraints()
                    
                    let topPoint = 0.55 * barGraphModel.topPoint + 0.15

                    self.bar.snp.makeConstraints { make in
                        make.centerX.equalToSuperview()
                        make.width.equalToSuperview().multipliedBy(barGraphModel.width)
                        make.height.equalToSuperview().multipliedBy(topPoint)
                        make.bottom.equalTo(self.separator.snp.top)
                    }
                    
                    DispatchQueue.main.async {
                        self.bar.layer.sublayers?.forEach({ subLayer in
                            subLayer.removeFromSuperlayer()
                        })

                        self.bar.setGradient(gradientColor: barGraphModel.gradientColor)
                        
                        self.setBarUI()
                    }
                }
            }
            .disposed(by: disposeBag)
        
    }
    
}
