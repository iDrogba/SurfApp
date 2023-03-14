//
//  DetailWeatherViewController.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/04.
//

import UIKit
import MapKit
import RxSwift
import SnapKit

class DetailWeatherViewController: UIViewController {
    let viewModel: DetailWeatherViewModel
    
    var label: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
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
        
        view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        viewModel.stormglassResponse
            .map { response in
                response.weather.first?.waveHeight?.description
            }
            .bind(to: label.rx.text)
    }
    

}

class DetailWeatherViewModel {
    let disposeBag = DisposeBag()
    var stormglassResponse = PublishSubject<StormglassResponse>()
    
    init(region: RegionModel) {
        StormglassNetworking.shared.requestWeather(region: region)
            .bind(to: self.stormglassResponse)
            .disposed(by: disposeBag)
    }
    
}
