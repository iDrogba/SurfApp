//
//  DetailCurrentWeatherView.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/29.
//

import UIKit
import SnapKit

class DetailCurrentWeatherView: UIView {
    private let labelStackView: UIStackView = .makeDefaultStackView(axis: .vertical, alignment: .center, distribution: .fillEqually, spacing: 0, layoutMargin: nil, color: .clear)
    
    let dataLabel: UILabel = {
        let label = UILabel.makeLabel(fontColor: .black, font: .systemFont(ofSize: 15, weight: .bold))
        label.textAlignment = .left
        
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel.makeLabel(fontColor: .gray, font: .systemFont(ofSize: 13, weight: .bold))
        label.textAlignment = .left
        
        return label
    }()

    init(title: String) {
        super.init(frame: CGRect())
        
        titleLabel.text = title
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        addSubview(labelStackView)
        labelStackView.addArrangedSubview(dataLabel)
        labelStackView.addArrangedSubview(titleLabel)
        
        labelStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
