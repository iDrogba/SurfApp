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
    
    init(mkPlaceMark: MKPlacemark) {
        viewModel = DetailWeatherViewModel(mkPlaceMark: mkPlaceMark)

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        viewModel = DetailWeatherViewModel(mkPlaceMark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 37.5, longitude: 127)))
        
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
    
    init(mkPlaceMark: MKPlacemark) {
        StormglassNetworking.shared.requestWeather(mkPlaceMark: mkPlaceMark)
            .bind(to: self.stormglassResponse)
            .disposed(by: disposeBag)
    }
    
}
