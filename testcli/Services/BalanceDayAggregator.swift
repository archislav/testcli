//
// Created by Sergey Morozov on 04.01.2021.
//

import Foundation

class BalanceDayAggregator {

    private static let continuousActivityMaxGapSec = TimeInterval(18)
    private static let longEnoughActivityMinDurationSec = TimeInterval(180)
    private static let significantRepeatedActivityMinGapSec = TimeInterval(2280)

    func aggregate(_ activities: [SingleActivity]) -> [DayBalance]? {
        let activitiesForDay = groupActivitiesForDay(activities)

        var result: [DayBalance] = []

        for (day, activities) in activitiesForDay {
            result.append(calculateDayBalance(day: day, activities: activities))
        }

        result.sort(by: { $0.date.compare($1.date) == .orderedAscending })

        return result
    }

    // группирует активности по дням
    private func groupActivitiesForDay(_ activities: [SingleActivity]) -> [Date: [SingleActivity]] {
        var result: [Date: [SingleActivity]] = [:]

        for activityInfo in activities {
            let activityDay = activityInfo.startDate.dayOfDate()
            if result[activityDay] == nil {
                result[activityDay] = []
            }

            result[activityDay]?.append(activityInfo)
        }

        return result
    }

    // вычисляет balance day для активностией в течении дня
    private func calculateDayBalance(day: Date, activities: [SingleActivity]) -> DayBalance {
        let activitiesForDayHour = groupActivitiesForDayHour(activities)

        let continuousActivitiesForDayHour = activitiesForDayHour.mapValues { groupContinuousActivities($0) }

        let longEnoughActivitiesForDayHour = continuousActivitiesForDayHour.mapValues {
            $0.filter { $0.duration >= BalanceDayAggregator.longEnoughActivityMinDurationSec }
        }

        let balancePointsForDayHour = longEnoughActivitiesForDayHour.mapValues { calculateBalancePointsForHour($0) }

        let balancePointsForDay = balancePointsForDayHour.values.reduce(0, +)

        return DayBalance(date: day, balancePoints: balancePointsForDay)
    }

    // вычисляет balance points часа
    private func calculateBalancePointsForHour(_ activities: [ContinuousActivity]) -> Int {
        if activities.count == 0 {
            return 0
        }
        else if activities.count == 1 {
            return 1
        }
        else {
            let firstActivityStart = activities.first?.startDate ?? Date.distantFuture
            let lastActivityStart = activities.last?.startDate ?? Date()

            let hasSignificantRepeatedActivity = firstActivityStart.addingTimeInterval(BalanceDayAggregator.significantRepeatedActivityMinGapSec) <= lastActivityStart
            return hasSignificantRepeatedActivity ? 2 : 1
        }
    }

    // собирает активности, между которыми меньше 18 секунд в единые куски
    private func groupContinuousActivities(_ activities: [SingleActivity]) -> [ContinuousActivity] {
        var result: [ContinuousActivity] = []

        if activities.count <= 1 {
            result.append(ContinuousActivity(activities))
            return result
        }

        for (index, activity) in activities.enumerated() {
            if index == 0 {
                result.append(ContinuousActivity([activity]))
                continue
            }

            if var previousActivity = result.last,
               previousActivity.endDate.addingTimeInterval(BalanceDayAggregator.continuousActivityMaxGapSec) >= activity.startDate {
                previousActivity.add(activity)
                result[result.count - 1] = previousActivity
            }
            else {
                result.append(ContinuousActivity([activity]))
                continue
            }
        }

        return result
    }

    // группирует активности по часам
    private func groupActivitiesForDayHour(_ activities: [SingleActivity]) -> [Date: [SingleActivity]] {
        var result: [Date: [SingleActivity]] = [:]

        for activity in activities {
            let activityDay = activity.startDate.dayHourOfDate()
            if result[activityDay] == nil {
                result[activityDay] = []
            }

            result[activityDay]?.append(activity)
        }

        return result
    }
}
