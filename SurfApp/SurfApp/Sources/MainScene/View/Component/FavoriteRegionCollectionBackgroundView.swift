//
//  FavoriteRegionCollectionBackgroundView.swift
//  SurfApp
//
//  Created by 김상현 on 2023/05/20.
//

import UIKit
import SnapKit

class FavoriteRegionCollectionBackgroundView: UIView {
    let stackView: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .center, distribution: .fillProportionally)
    let imageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage(named: "character")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "There is no favorite beach.\nFind some beaches by searching.".localized
        label.textAlignment = .center
        label.textColor = .customGray
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 5
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
       
        setLayout()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        addSubview(stackView)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(descriptionLabel)
        
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
        }
    }
}
