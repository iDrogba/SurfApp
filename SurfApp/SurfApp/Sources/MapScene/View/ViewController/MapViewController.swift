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
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        let annotationIdentifier = "AnnotationIdentifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = annotation
        }
        
        viewModel.defaultRegionAnnotations
            .take(1)
            .subscribe(onNext: {
                if $0.contains(where: {
                    $0.title == annotation.title
                }) {
                    let pinImage = UIImage(named: "grayStar")
                    annotationView!.image = pinImage
                } else {
                    let pinImage = UIImage(named: "star")
                    annotationView!.image = pinImage
                }
            })
            .disposed(by: viewModel.disposeBag)

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        toggleMapLocation(isActivated: true)
        
        if let annotation = view.annotation {
            let regionName = annotation.title ?? ""
            let locality = annotation.subtitle ?? ""
            
            viewModel.updateSelectedMapLocation(regionName: regionName, locality: locality)
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        toggleMapLocation(isActivated: false)
    }
}
