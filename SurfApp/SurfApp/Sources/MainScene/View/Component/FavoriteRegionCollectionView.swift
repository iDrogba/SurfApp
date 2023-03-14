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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

// MARK: CollectionViewDelegate
extension FavoriteRegionCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellWidth = collectionView.bounds.width * 0.88
        var cellHeight = (collectionView.bounds.height - 80) / 4.5
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
}

class FavoriteRegionCollectionViewCell: UICollectionViewCell {
    
}
