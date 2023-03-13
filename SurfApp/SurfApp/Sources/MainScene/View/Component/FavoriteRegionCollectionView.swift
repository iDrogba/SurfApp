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
        }
        
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
        backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

extension FavoriteRegionCollectionView: UICollectionViewDelegateFlowLayout {
    
}

class FavoriteRegionCollectionViewCell: UICollectionViewCell {
    
}
