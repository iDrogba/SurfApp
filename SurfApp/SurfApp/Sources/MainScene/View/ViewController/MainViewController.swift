//
//  MainViewController.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/03.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import MapKit

class MainViewController: UIViewController {
    let viewModel = MainViewModel()
    let disposeBag = DisposeBag()
    
    let mapViewController = MapViewController()
    
    private lazy var searchController = UISearchController()
    private lazy var searchTableView = SearchTableView(frame: .zero, style: .plain)
    private lazy var favoriteRegionCollectionView = FavoriteRegionCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private lazy var mapButton: UIButton = {
        let button = UIButton()
        var mapImage = UIImage(systemName: "map.circle.fill")!.withTintColor(.customBlue, renderingMode: .alwaysOriginal)
        button.setImage(mapImage, for: .normal)
        
        let pointSize: CGFloat = 50
        let imageConfig = UIImage.SymbolConfiguration(pointSize: pointSize)
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.preferredSymbolConfigurationForImage = imageConfig
            button.configuration = config
        } else {
            button.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
        }
        button.backgroundColor = .white
        button.layer.shadowColor = UIColor.lightGray.cgColor
        button.layer.shadowOpacity = 0.8
        button.layer.shadowOffset = CGSize.zero
        button.layer.shadowRadius = 10
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .defaultBackground

        addSubViews()
        setLayOut()
        bindSearch()
        bindFavoriteRegionCollectionView()
        setMapViewController()
        
        viewModel.searchCompleter.delegate = self
        
        mapButton.addTarget(self, action: #selector(onTapMapButton), for: .touchUpInside)
    }
    
    @objc
    private func onTapMapButton() {
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.mapButton.layer.cornerRadius = self.mapButton.frame.width / 1.5
        }
        setNavigationBar()
    }
    
    private func setMapViewController() {
        mapViewController.modalPresentationStyle = .fullScreen
        mapViewController.modalTransitionStyle = .coverVertical
        
        viewModel.favoriteRegionCellData
            .bind(to: mapViewController.viewModel.favoriteRegionData)
            .disposed(by: mapViewController.viewModel.disposeBag)
    }
    
    private func setNavigationBar() {
        let placeHolder = "해변 이름으로 검색"
        searchController.searchBar.placeholder = placeHolder
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        navigationController?.navigationBar.standardAppearance = appearance
    }
    
    private func bindSearch() {
        searchController.searchBar.rx.text
            .orEmpty
            .debounce(RxTimeInterval.microseconds(10), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: viewModel.searchCompleter.rx.queryFragment)
            .disposed(by: disposeBag)

        viewModel.searchResults.asObservable()
            .bind(to: searchTableView.rx.items(cellIdentifier: SearchTableViewCell.identifier, cellType: SearchTableViewCell.self)) { item, element, cell in
                cell.setData(text: element.title)
            }
            .disposed(by: disposeBag)
        
        searchTableView.rx.itemSelected
            .map {
                self.searchController.searchBar.resignFirstResponder()
                self.searchController.searchBar.text = nil
                
                self.animateHideSearchTableView(true)
                self.searchController.searchBar.rx.text.onNext(nil)
                
                return $0.row
            }
            .withLatestFrom(viewModel.searchResults) { index, searchResults in
                searchResults[index]
            }
            .subscribe(onNext: { mkLocalSearchCompletion in
                let searchRequest = MKLocalSearch.Request(completion: mkLocalSearchCompletion)
                let search = MKLocalSearch(request: searchRequest)
                
                search.start { response, error in
                    guard let response = response else {
                        print("Error: \(error?.localizedDescription ?? "Unknown error").")
                        return
                    }
                    if let placeMark = response.mapItems.first?.placemark {
                        let region = RegionModel(placeMark: placeMark)
                        let viewController = DetailWeatherViewController(region: region)
                        viewController.modalPresentationStyle = .fullScreen
                        self.navigationController?.pushViewController(viewController, animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindFavoriteRegionCollectionView() {
        viewModel.favoriteRegionCellData
            .bind(to: favoriteRegionCollectionView.rx.items(cellIdentifier: FavoriteRegionCollectionViewCell.identifier, cellType: FavoriteRegionCollectionViewCell.self)) { item, element, cell in
                cell.setData(weather: element.value)
            }
            .disposed(by: disposeBag)
        
        favoriteRegionCollectionView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                if let cell = self.favoriteRegionCollectionView.cellForItem(at: indexPath) as? FavoriteRegionCollectionViewCell {
                    let region = cell.region!
                    let viewController = DetailWeatherViewController(region: region)
                    viewController.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: UI
extension MainViewController {
    func addSubViews() {
        view.addSubview(favoriteRegionCollectionView)
        searchController.view.addSubview(searchTableView)
        view.addSubview(mapButton)
    }
    
    func setLayOut() {
        favoriteRegionCollectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.verticalEdges.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        searchTableView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(searchController.view.safeAreaLayoutGuide)
            make.top.equalTo(searchController.view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        mapButton.snp.makeConstraints { make in
            make.width.equalTo(view.snp.width).multipliedBy(0.17)
            make.height.equalTo(mapButton.snp.width)
            make.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(24)
        }
    }
}

extension MainViewController: UISearchControllerDelegate {
    func presentSearchController(_ searchController: UISearchController) {
        animateHideSearchTableView(false)
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        animateHideSearchTableView(true)
    }
    
    private func animateHideSearchTableView(_ isHidden: Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) { [weak self] in
            guard let self = self else { return }
            if isHidden {
                self.searchTableView.alpha = 0.0
            } else {
                self.searchTableView.alpha = 1.0
            }
            self.searchTableView.isHidden = isHidden
            self.favoriteRegionCollectionView.isHidden = !isHidden
        }
    }
}

extension MainViewController: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        viewModel.searchResults.onNext(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
