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
    
    private lazy var searchController = UISearchController()
    private lazy var searchTableView = SearchTableView(frame: .zero, style: .plain)
    private lazy var favoriteRegionCollectionView = FavoriteRegionCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setNavigationBar()
        addSubViews()
        setLayOut()
        bindSearch()
        
        viewModel.searchCompleter.delegate = self
    }
    
    private func setNavigationBar() {
        let placeHolder = "해변 이름으로 검색"
        searchController.searchBar.placeholder = placeHolder
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        navigationController?.navigationBar.standardAppearance = appearance
    }
    
    func bindSearch() {
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
                self.searchController.dismiss(animated: true)
                self.searchController.searchBar.text = nil
                self.animateHideSearchTableView(true)
                
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
                        self.present(viewController, animated: true)
                    }
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
    }
    
    func setLayOut() {
        favoriteRegionCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        searchTableView.snp.makeConstraints { make in
            make.edges.equalTo(searchController.view.safeAreaLayoutGuide)
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
                self.searchTableView.isHidden = isHidden
            }
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
