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
    
//    func convertToKoreanDate() -> String {
//        let df = DateFormatter()
//        df.locale = Locale(identifier: "ko_KR")
//        df.timeZone = TimeZone(abbreviation: "KST")
//        df.dateFormat = "M.d(E) a HH시"
//
//        return df.string(from: self)
//    }
    func isToday() -> Bool {
        let calendar = Calendar.current
        let calendarComponenets: Set<Calendar.Component> = [.day, .month, .year]
        let components = calendar.dateComponents(calendarComponenets, from: self)
        let todayComponents = calendar.dateComponents(calendarComponenets, from: Date())

        return todayComponents.year == components.year && todayComponents.month == components.month && todayComponents.day == components.day
    }
    
    func dateFormatA() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "M.d(E) a HH시"

        return df.string(from: self)
    }
    
    func weekDay() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "E"

        return df.string(from: self)
    }
    
    /// n월.m일
    func monthAndDay() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "M.d"

        return df.string(from: self)
    }
    
    func time() -> String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "ko_KR")
        df.dateFormat = "H시"

        return df.string(from: self)
    }
}
