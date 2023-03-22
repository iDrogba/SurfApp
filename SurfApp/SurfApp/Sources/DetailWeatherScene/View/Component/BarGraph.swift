//
//  BarGraph.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/21.
//

import UIKit
import SnapKit

class BarGraph: UICollectionView {
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        super.init(frame: CGRect(origin: .zero, size: .zero), collectionViewLayout: layout)
        
        delegate = self
        self.register(BarGraphCell.self, forCellWithReuseIdentifier: BarGraphCell.identifier)
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
    
    let bar: UIView = {
        let bar = UIView()
        
        return bar
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setSubview() {
        contentView.addSubview(bar)
    }
    
    func setUI(barGraphModel: BarGraphModel) {
//    accessoryView: (top: UIView?, bottom: UIView?)?
        bar.backgroundColor = barGraphModel.color
        
        let topInset = contentView.bounds.height * (1 - barGraphModel.topPoint)
        let bottomInset = contentView.bounds.height * barGraphModel.bottomPoint
        
        bar.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(barGraphModel.width)
            make.top.equalToSuperview().inset(topInset)
            make.bottom.equalToSuperview().inset(bottomInset)
        }
    }
    
    
}
