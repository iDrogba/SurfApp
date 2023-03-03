//
//  Date+.swift
//  SurfApp
//
//  Created by 김상현 on 2023/03/04.
//

import Foundation

extension Date {
    
    //현지 시각이 00시일때의 UTC
    static var yesterdayUTC: Date {
        let date = Date()
        let midnight = Calendar.current.dateComponents([.year, .month, .day], from: date)
        let dateCom = DateComponents(timeZone: TimeZone(identifier: "UTC"), year: midnight.year, month: midnight.month, day: midnight.day, hour: 0, minute: 0)
        let timeZoneDifference = TimeInterval(TimeZone.current.secondsFromGMT())
        let resultDate = Calendar.current.date(from: dateCom)?.addingTimeInterval(-timeZoneDifference) ?? Date()
        
        return resultDate
    }
    
}
