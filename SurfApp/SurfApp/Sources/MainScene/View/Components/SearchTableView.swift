//
//  SearchTableView.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/04.
//

import UIKit
import SnapKit

class SearchTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        delegate = self
        register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

extension SearchTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = tableView.bounds.height * 0.05
        
        return height
    }
}

class SearchTableViewCell: UITableViewCell {
    var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.verticalEdges.equalTo(contentView.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(contentView.safeAreaLayoutGuide).inset(20)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setData(text: String) {
        label.text = text
    }
}
