//
//  DetailWeatherViewController.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/04.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import SnapKit

class DetailWeatherViewController: UIViewController {
    let disposeBag = DisposeBag()
    let viewModel: DetailWeatherViewModel
    
    var waveBarGraph = BarGraph()
    
    init(region: RegionModel) {
        viewModel = DetailWeatherViewModel(region: region)

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        let defaultRegionPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.5, longitude: 128))
        viewModel = DetailWeatherViewModel(region: RegionModel(placeMark: defaultRegionPlaceMark))
        
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(waveBarGraph)
        
        waveBarGraph.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(1)
        }
        
        viewModel.waveGraphModels.asObservable()
            .bind(to: waveBarGraph.rx.items(cellIdentifier: BarGraphCell.identifier, cellType: BarGraphCell.self)) { item, element, cell in
                cell.setUI(barGraphModel: element)
            }
            .disposed(by: disposeBag)
            
    }
    

}
