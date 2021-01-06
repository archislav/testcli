//
//  main.swift
//  testcli
//
//  Created by Sergey Morozov on 04.01.2021.
//
//

// скрипт принимает на вход 2 параметра:
// 1) путь к исходному CSV-файлу
// 2) путь к выходному CSV-файлу

import Foundation
import os.log

let inputFilePath = CommandLine.arguments[1]
let outputFilePath = CommandLine.arguments[2]

guard let lineReader = LineReader(path: inputFilePath) else {
    os_log(.error, "can't read file: \(inputFilePath)")
    exit(-1)
}

let inputParser = AppleHealthCSVParser(lineReader: lineReader)

guard let activities = inputParser.parse() else {
    os_log(.error, "can't parse file: \(inputFilePath)")
    exit(-1)
}

let aggregator = BalanceDayAggregator()

guard let dayBalanceList = aggregator.aggregate(activities) else {
    os_log(.error, "can't aggregate activities")
    exit(-1)
}

let csvConverter = BalanceDayCSVConverter()
let balanceDayCSV = csvConverter.convert(dayBalanceList)

do {
    guard let outputFileUrl = URL(string: "file://" + outputFilePath) else {
        os_log(.error, "can't write to output file: \(outputFilePath)")
        exit(-1)
    }
    try balanceDayCSV.write(to: outputFileUrl, atomically: true, encoding: String.Encoding.utf8)
} catch {
    os_log(.error, "error while writing file: \(error.localizedDescription)")
    exit(-1)
}

