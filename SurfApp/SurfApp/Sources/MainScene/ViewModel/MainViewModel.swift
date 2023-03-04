//
//  MainViewModel.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/03.
//

import Foundation
import MapKit
import RxCocoa
import RxSwift

class MainViewModel {
    var searchCompleter: MKLocalSearchCompleter = MKLocalSearchCompleter()
    var searchResults = PublishSubject<[MKLocalSearchCompletion]>()
    
    init() {
        setSearchCompleter()
    }
    
    func setSearchCompleter() {
        searchCompleter.resultTypes = .pointOfInterest
        searchCompleter.pointOfInterestFilter = MKPointOfInterestFilter.init(including: [.beach])
    }
}
