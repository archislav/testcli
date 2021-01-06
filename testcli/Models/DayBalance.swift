//
// Created by Sergey Morozov on 04.01.2021.
//

import Foundation

struct DayBalance {
    let date: Date
    let balancePoints: Int

    // Balance Day = 100% * balance_points / 10
    var balanceDay: Double {
        return Double(balancePoints) * 10
    }
}
