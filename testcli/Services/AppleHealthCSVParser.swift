//
// Created by Sergey Morozov on 04.01.2021.
//

import Foundation
import os.log

class AppleHealthCSVParser {

    // MARK: - Structs
    struct HeaderInfo {
        fileprivate static let startActivityDateAttrName = "startDate"
        fileprivate static let endActivityDateAttrName = "endDate"
        fileprivate static let stepCountAttrName = "value"

        let startActivityDateAttrIndex: Int
        let endActivityDateAttrIndex: Int
        let stepCountAttrIndex: Int
    }

    // MARK: - Constants
    private static let csvSeparator = ","

    // MARK: - Fields
    private let inputReader: LineReader
    private var headerInfo: HeaderInfo?

    /// форматтер для дат вида 2020-03-20 00:04:02
    private lazy var inputDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd' 'HH:mm:ss"
        formatter.calendar = Date.defaultCalendar
        formatter.timeZone = Date.defaultTimezone
        return formatter
    }()

    init(lineReader: LineReader) {
        self.inputReader = lineReader
    }

    func parse() -> [SingleActivity]? {
        guard let headerLine = inputReader.nextLine else {
            os_log(.error, "can't read header line")
            return nil
        }

        guard let headerInfo = parseHeader(from: headerLine) else {
            os_log(.error, "can't parse header line")
            return nil
        }

        self.headerInfo = headerInfo

        var activities: [SingleActivity] = []
        while let line = inputReader.nextLine {
            if let activity = parseActivity(from: line) {
                activities.append(activity)
            }
        }

        return activities
    }

    private func parseHeader(from headerCSVLine: String) -> HeaderInfo? {
        let headerFields = headerCSVLine.components(separatedBy: AppleHealthCSVParser.csvSeparator)

        guard let startActivityDateAttrIndex = headerFields.firstIndex(of: AppleHealthCSVParser.HeaderInfo.startActivityDateAttrName),
              let endActivityDateAttrIndex = headerFields.firstIndex(of: AppleHealthCSVParser.HeaderInfo.endActivityDateAttrName),
              let stepCountAttrIndex = headerFields.firstIndex(of: AppleHealthCSVParser.HeaderInfo.stepCountAttrName) else {
            os_log(.error, "Can't find field index")

            return nil
        }

        return HeaderInfo(startActivityDateAttrIndex: startActivityDateAttrIndex,
                endActivityDateAttrIndex: endActivityDateAttrIndex,
                stepCountAttrIndex: stepCountAttrIndex)
    }

    private func parseActivity(from activityCSVLine: String) -> SingleActivity? {
        guard let headerInfo = headerInfo else {
            return nil
        }

        let activityFields = parseCSVLine(activityCSVLine)

        guard headerInfo.startActivityDateAttrIndex < activityFields.count,
              let startDate = inputDateFormatter.date(from: activityFields[headerInfo.startActivityDateAttrIndex]) else {
            os_log(.error, "Can't find start date")
            return nil
        }

        guard headerInfo.endActivityDateAttrIndex < activityFields.count,
              let endDate = inputDateFormatter.date(from: activityFields[headerInfo.endActivityDateAttrIndex]) else {
            os_log(.error, "Can't find end date")
            return nil
        }

        guard headerInfo.stepCountAttrIndex < activityFields.count,
              let stepCount = Int(activityFields[headerInfo.stepCountAttrIndex]) else {
            os_log(.error, "Can't find step count")
            return nil
        }

        return SingleActivity(startDate: startDate, endDate: endDate, stepCount: stepCount)
    }

    private func parseCSVLine(_ csvLine: String) -> [String] {
        var result: [String] = []

        let dirtyFields = csvLine.components(separatedBy: AppleHealthCSVParser.csvSeparator)

        // собираем поля содержащие строки
        var stringField: String? = nil
        for dirtyField in dirtyFields {
            if dirtyField.starts(with: "\"") {
                stringField = dirtyField
                continue
            }
            if dirtyField.hasSuffix("\"") {
                result.append((stringField ?? "") + dirtyField)
                stringField = nil
                continue
            }

            if stringField != nil {
                stringField = (stringField ?? "") + dirtyField
            }
            else {
                result.append(dirtyField)
            }
        }

        return result
    }
}

