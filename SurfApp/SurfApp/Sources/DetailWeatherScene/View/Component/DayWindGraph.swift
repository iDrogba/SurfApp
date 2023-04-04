//
//  DayWindGraph.swift
//  SurfApp
//
//  Created by 김상현 on 2023/04/02.
//

import UIKit
import Charts
import RxSwift

class DayWindGraph: LineChartView {
    let disposeBag = DisposeBag()
    let dayWindGraphDatas = PublishSubject<LineChartData>()
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 1
        numberFormatter.multiplier = 1.0
        
        return numberFormatter
    }()
    
    let topSeperator: UIView = {
        let view = UIView()
        view.backgroundColor = .customChartGray
        
        return view
    }()
    
    let bottomSeperator: UIView = {
        let view = UIView()
        view.backgroundColor = .customChartGray
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setSeperator()
        setRxData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        backgroundColor = .customLightGray
        
        let xScale = 1.0
        let yScale = 1.0
        zoom(scaleX: xScale, scaleY: yScale, x: 0, y: 0)
        
        rightAxis.enabled = false

        leftAxis.enabled = true
        leftAxis.drawLabelsEnabled = false
        leftAxis.drawAxisLineEnabled = false
        leftAxis.gridColor = .customChartGray

        xAxis.enabled = true
        xAxis.drawLabelsEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.gridColor = .customChartGray

        borderColor = .customChartGray
        
        animate(xAxisDuration: 0, yAxisDuration: 1)
        doubleTapToZoomEnabled = false
        scaleXEnabled = false
        scaleYEnabled = false
        highlightPerTapEnabled = false
        highlightPerDragEnabled = false
        drawBordersEnabled = false
        legend.enabled = false

        xAxis.gridLineDashLengths = [5, 3]
        leftAxis.gridLineDashLengths = [5, 3]
    
    }
    
    private func setSeperator() {
        addSubview(topSeperator)
        addSubview(bottomSeperator)
        
        topSeperator.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
        
        bottomSeperator.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func setRxData() {
        dayWindGraphDatas
            .debug()
            .subscribe { lineChartData in
                self.data = lineChartData.element
                self.data?.notifyDataChanged()
                self.data?.setValueFormatter(DefaultValueFormatter(formatter: self.numberFormatter))
            }
            .disposed(by: disposeBag)
    }
}
