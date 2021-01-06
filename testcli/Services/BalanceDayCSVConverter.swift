//
// Created by Sergey Morozov on 05.01.2021.
//

import Foundation

class BalanceDayCSVConverter {
    private static let newLine = "\r\n"
    private static let csvSeparator = ","
    private static let headerAttrs = ["day", "balance_points", "balance_day"]

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.calendar = Date.defaultCalendar
        formatter.timeZone = Date.defaultTimezone
        return formatter
    }()

    func convert(_ dayBalanceList: [DayBalance]) -> String {
        return toCSV(BalanceDayCSVConverter.headerAttrs) + BalanceDayCSVConverter.newLine +
                dayBalanceList.map { toCSV($0) }.joined(separator: BalanceDayCSVConverter.newLine)
    }

    private func toCSV(_ dayBalance: DayBalance) -> String {
        let stringValues = [dateFormatter.string(from: dayBalance.date), String(dayBalance.balancePoints), String(dayBalance.balanceDay)]
        return toCSV(stringValues)
    }

    private func toCSV(_ stringValues: [String]) -> String {
        return stringValues.joined(separator: BalanceDayCSVConverter.csvSeparator)
    }
}
