//
// Created by Sergey Morozov on 05.01.2021.
//

import Foundation

struct SingleActivity {
    // todo: добавить проверку валидности startDate, endDate при создании

    let startDate: Date
    let endDate: Date
    let stepCount: Int
    var duration: TimeInterval {
        return endDate.timeIntervalSince(startDate)
    }
}
