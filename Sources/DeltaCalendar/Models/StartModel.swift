import Foundation

// MARK: - StartModel

public struct StartModel {
    let pickingYearData: PickingYearModel
    let showTimeData: ShowTimeModel?
    let colors: Colors
    let orderGap: OrderingGap?
    let isDisablePreviousDays: Bool
    let isShowPickingTime: Bool

    public init(
        pickingYearData: PickingYearModel,
        showTimeData: ShowTimeModel?,
        colors: Colors,
        orderGap: OrderingGap?,
        isDisablePreviousDays: Bool,
        isShowPickingTime: Bool
    ) {
        self.pickingYearData = pickingYearData
        self.showTimeData = showTimeData
        self.colors = colors
        self.orderGap = orderGap
        self.isDisablePreviousDays = isDisablePreviousDays
        self.isShowPickingTime = isShowPickingTime
    }
}

// MARK: - OrderingGap

public struct OrderingGap {
    let minutes: Int

    public init(minutes: Int) {
        self.minutes = minutes
    }
}

// MARK: - PickingYearModel

public struct PickingYearModel {
    let from: Int
    let to: Int

    public init(from: Int, to: Int) {
        guard from <= to else { fatalError(CalendarError.fromToYears.description) }

        self.from = from
        self.to = to
    }
}

// MARK: - ShowTimeModel

public struct ShowTimeModel {
    let data: [DayTimeStartModel]
    let offset: Int

    public init(data: [DayTimeStartModel], offset: Int) {
        guard offset >= 1 else { fatalError(CalendarError.timeOffset.description) }

        self.data = data
        self.offset = offset
    }
}

// MARK: - DayTimeStartModel

public struct DayTimeStartModel {
    let weekday: Int
    let startDate: Date
    let endDate: Date

    public init(weekday: Int, startDate: String, endDate: String) {
        guard (1...7).contains(weekday) else {
            fatalError(CalendarError.weekday(weekday).description)
        }

        let format = Resources.timeFormat
        let timeFormatter = DateFormatter.build(format: format)

        var calendar = timeFormatter.calendar ?? .current
        calendar.timeZone = timeFormatter.timeZone

        guard let start = timeFormatter.date(from: startDate),
              let end = timeFormatter.date(from: endDate)
        else { fatalError(CalendarError.timeFormat(format).description) }

        let startHour = calendar.component(.hour, from: start)
        let startMin = calendar.component(.minute, from: start)

        let endHour = calendar.component(.hour, from: end)
        let endMin = calendar.component(.minute, from: end)

        guard startHour <= endHour else {
            fatalError(CalendarError.startEndTime.description)
        }

        if startHour == endHour, startMin >= endMin {
            fatalError(CalendarError.startEndTime.description)
        }

        let today = Resources.today

        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let day = calendar.component(.day, from: today)

        let startComponents = DateComponents(year: year, month: month, day: day, hour: startHour, minute: startMin)
        let endComponents = DateComponents(year: year, month: month, day: day, hour: endHour, minute: endMin)

        self.startDate = calendar.date(from: startComponents)!
        self.endDate = calendar.date(from: endComponents)!
        self.weekday = weekday
    }
}
