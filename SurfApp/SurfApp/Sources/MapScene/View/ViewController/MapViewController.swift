//
//  MapViewController.swift
//  SurfApp
//
//  Created by 김상현 on 2023/04/20.
//

import UIKit
import MapKit
import SnapKit
import RxSwift
import RxCocoa

class MapViewController: UIViewController {
    let viewModel = MapViewModel()
    private lazy var mapLocationDescriptionView: MapLocationDescriptionView = MapLocationDescriptionView()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.delegate = self
        mapView.register(RegionAnnotationView.self, forAnnotationViewWithReuseIdentifier: RegionAnnotationView.identifier)
        mapView.register(RegionClusterView.self, forAnnotationViewWithReuseIdentifier: RegionClusterView.identifier)
        
        return mapView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapLocationDescriptionView.isHidden = true
        setLayout()
        setData()
        setTapAction()
        setNavigationBar()
    }
    
    private func setLayout() {
        view.addSubview(mapView)
        view.addSubview(mapLocationDescriptionView)
        
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        mapLocationDescriptionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.9)
            make.height.equalToSuperview().multipliedBy(0.19)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    private func setData() {
        viewModel.defaultRegionAnnotations
            .subscribe(onNext: {
                $0.forEach{
                    self.mapView.addAnnotation($0)
                }
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.favoriteRegionAnnotations
            .subscribe(onNext: {
                $0.keys.forEach {
                    self.mapView.addAnnotation($0)
                }
            })
            .disposed(by: viewModel.disposeBag)
        
        viewModel.selectedMapLocationData
            .bind(to: mapLocationDescriptionView.mapLocationData)
            .disposed(by: mapLocationDescriptionView.disposeBag)
    }

    private func toggleMapLocation(isActivated: Bool) {
        mapLocationDescriptionView.isHidden = !isActivated
    }
    
    private func setTapAction() {
        let onTapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapMapLocationDescriptionView))
        mapLocationDescriptionView.addGestureRecognizer(onTapGesture)
    }
    
    @objc
    private func onTapMapLocationDescriptionView() {
        viewModel.selectedMapLocation
            .take(1)
            .subscribe { regionModel in
                let detailWeatherViewController = DetailWeatherViewController(region: regionModel)
                self.navigationController?.pushViewController(detailWeatherViewController, animated: true)
            }
            .disposed(by: viewModel.disposeBag)
    }
    
    private func setNavigationBar() {
        let chevronImage = UIImage(systemName: "chevron.left")?.withTintColor(.black, renderingMode: .alwaysOriginal)
        let backButtonItem = UIBarButtonItem(image: chevronImage, style: .plain, target: self, action: #selector(onTapNavigationBackButton))
        
        navigationItem.setLeftBarButtonItems([backButtonItem], animated: false)
    }
    
    @objc
    private func onTapNavigationBackButton() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is MKPointAnnotation:
            guard let regionAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: RegionAnnotationView.identifier, for: annotation) as? RegionAnnotationView else {
                return MKAnnotationView()
            }
            
            regionAnnotationView.canShowCallout = true

            regionAnnotationView.annotationLabel.text = annotation.title!
            regionAnnotationView.setUI()
            
            viewModel.defaultRegionAnnotations
                .take(1)
                .subscribe(onNext: {
                    if $0.contains(where: {
                        $0.title == annotation.title
                    }) {
                        let pinImage = UIImage(named: "grayStar")
                        regionAnnotationView.image = pinImage
                        regionAnnotationView.zPriority = .min
                    } else {
                        let pinImage = UIImage(named: "star")
                        regionAnnotationView.image = pinImage
                        regionAnnotationView.zPriority = .max
                    }
                })
                .disposed(by: viewModel.disposeBag)
            
            regionAnnotationView.clusteringIdentifier = "mapItemClustered"

            return regionAnnotationView
        case is MKClusterAnnotation:
            guard let clusterAnnotation = annotation as? MKClusterAnnotation else { return MKAnnotationView() }
            guard let regionClusterView = mapView.dequeueReusableAnnotationView(withIdentifier: RegionClusterView.identifier, for: annotation) as? RegionClusterView else { return MKAnnotationView() }
            
            regionClusterView.countLabel.text = clusterAnnotation.memberAnnotations.count.description
            
            viewModel.favoriteRegionAnnotations
                .take(1)
                .subscribe {
                    if $0.keys.contains(where: { favoriteRegionAnnotation in
                        clusterAnnotation.memberAnnotations.contains { clusterAnnotation in
                            clusterAnnotation.title == favoriteRegionAnnotation.title
                        }
                    }) {
                        regionClusterView.countLabel.textColor = .customOrange
                        regionClusterView.countLabel.backgroundColor = .white
                    } else {
                        regionClusterView.countLabel.textColor = .white
                        regionClusterView.countLabel.backgroundColor = .customGray
                    }
                }
                .disposed(by: viewModel.disposeBag)

            return regionClusterView
        default:
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        switch view {
        case is RegionAnnotationView:
            toggleMapLocation(isActivated: true)

            if let annotation = view.annotation {
                let regionName = annotation.title ?? ""
                let locality = annotation.subtitle ?? ""
                
                viewModel.updateSelectedMapLocation(regionName: regionName, locality: locality)
            }
            
        case is RegionClusterView:
            let currentSpan = mapView.region.span
            let zoomSpan = MKCoordinateSpan(latitudeDelta: currentSpan.latitudeDelta / 4.0, longitudeDelta: currentSpan.longitudeDelta / 4.0)
            let zoomCoordinate = view.annotation?.coordinate ?? mapView.region.center
            let zoomed = MKCoordinateRegion(center: zoomCoordinate, span: zoomSpan)
            mapView.setRegion(zoomed, animated: true)
            
        default:
            return
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        toggleMapLocation(isActivated: false)
    }
}

class RegionAnnotationView: MKAnnotationView {
    let annotationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 3
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 10)
        
        return label
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(annotationLabel)
                
        annotationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.snp.bottom).offset(-8)
            make.height.equalTo(15)
            make.width.equalTo(100)
        }
    }
}

final class RegionClusterView: MKAnnotationView {

    // MARK: Initialization
    let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .customGray
        label.numberOfLines = 3
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 13)
        
        return label
    }()

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

        displayPriority = .defaultHigh
        collisionMode = .circle

        frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        layer.cornerRadius = frame.width / 2
        layer.masksToBounds = true
        
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Setup
    private func setupUI() {
        addSubview(countLabel)
    
        countLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
