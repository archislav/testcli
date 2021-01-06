//
// Created by Sergey Morozov on 05.01.2021.
//

import Foundation

extension Date {

    func dayOfDate() -> Date {
        let dayDateComponents = Date.defaultCalendar.dateComponents([.year, .month, .day], from: self)
        return Date.defaultCalendar.date(from: dayDateComponents) ?? Date()
    }

    func dayHourOfDate() -> Date {
        let dayHourDateComponents = Date.defaultCalendar.dateComponents([.year, .month, .day, .hour], from: self)
        return Date.defaultCalendar.date(from: dayHourDateComponents) ?? Date()
    }

    static var defaultCalendar: Calendar {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = defaultTimezone
        return calendar
    }

    static var defaultTimezone: TimeZone {
        return TimeZone(secondsFromGMT: 0) ?? TimeZone.current
    }
}