//
//  DetailCurrentWeatherView.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/29.
//

import UIKit
import SnapKit

class DetailCurrentWeatherView: UIView {
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    private let labelStackView: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .center, distribution: .fill, spacing: 0, layoutMargin: nil, color: .clear)
    private let titleLabel: UILabel = .makeLabel(color: .black, font: .systemFont(ofSize: 13, weight: .bold))
    let dataLabel: UILabel = .makeLabel(text: "12.12", color: .customGreen, font: .systemFont(ofSize: 16, weight: .bold))
    
    init(iconImage: UIImage, title: String) {
        super.init(frame: CGRect())
        
        iconImageView.image = iconImage
        titleLabel.text = title
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        addSubview(iconImageView)
        addSubview(labelStackView)
        labelStackView.addArrangedSubview(titleLabel)
        labelStackView.addArrangedSubview(dataLabel)
        
        iconImageView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.equalTo(iconImageView.snp.height)
        }
        
        labelStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalTo(iconImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
        }
    }
    
}
