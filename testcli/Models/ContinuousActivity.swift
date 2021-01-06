//
// Created by Sergey Morozov on 05.01.2021.
//

import Foundation

struct ContinuousActivity {

    private var activities: [SingleActivity]

    var startDate: Date {
        return activities.first?.startDate ?? Date()
    }

    var endDate: Date {
        return activities.last?.endDate ?? Date()
    }

    var duration: TimeInterval {
        return activities.map { $0.duration }.reduce(TimeInterval(0), +)
    }

    init(_ activities: [SingleActivity]) {
        // todo: добавить проверку, что записи упорядочены
        self.activities = activities
    }

    mutating func add(_ info: SingleActivity) {
        // todo: добавить проверку, что запись можно добавить в конец
        activities.append(info)
    }
}
