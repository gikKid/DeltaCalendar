import Foundation
import Combine

internal protocol DeltaCalendarViewModelDelegate: AnyObject {
    func calendarConfigured()
    func monthFilled(id: MonthItem.ID)
}

internal protocol DeltaCalendarViewModelProtocol: AnyObject {

    var delegate: DeltaCalendarViewModelDelegate? { get set }
    var yearItems: [YearItem] { get }
    var calendar: Calendar { get }

    func updateSelecting(at date: SelectedModel, value: Bool)
    func toggleYearSelecting(_ data: UpdateSelectingModel)
    func date(selectedData: SelectedModel, timeIndex: Int) -> Date?
    func month(yearIndex: Int, monthIndex: Int, isDisablePreviousDays: Bool, showTimeData: ShowTimeModel?) -> MonthItem
}

internal final class DeltaCalendarViewModel: DeltaCalendarViewModelProtocol {

    public weak var delegate: DeltaCalendarViewModelDelegate?
    private let timeFormatter = DateFormatter.build(format: Resources.timeFormat)
    private(set) var yearItems: [YearItem] = YearItem.mockData()
    private lazy var cachedMonths: [String: MonthItem] = [:]

    public var calendar: Calendar {
        var calendar = self.timeFormatter.calendar ?? .current
        calendar.timeZone = self.timeFormatter.timeZone
        return calendar
    }

    init(startData: StartModel) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.yearItems = self.createContent(startData)

            DispatchQueue.main.async {
                self.delegate?.calendarConfigured()
            }
        }
    }

    func updateSelecting(at date: SelectedModel, value: Bool) {
        self.yearItems[date.yearIndex].months[date.monthIndex].days[date.dayIndex]
            .isSelected = value

        let monthId = self.yearItems[date.yearIndex].months[date.monthIndex].id

        self.cachedMonths[monthId]?.days[date.dayIndex].isSelected = value
    }

    func toggleYearSelecting(_ data: UpdateSelectingModel) {
        self.yearItems[data.prevIndex].isSelected.toggle()
        self.yearItems[data.index].isSelected.toggle()
    }

    func date(selectedData: SelectedModel, timeIndex: Int) -> Date? {
        let day = self.yearItems[selectedData.yearIndex].months[selectedData.monthIndex].days[selectedData.dayIndex].data
        let time = day.timeData[timeIndex].title

        guard let date = day.date else { return nil }

        let dayText = DateFormatter.build(format: Resources.isoFormat).string(from: date)

        return DateFormatter.build(format: Resources.dateFormat).date(from: "\(dayText) \(time)")
    }

    func month(yearIndex: Int, monthIndex: Int, isDisablePreviousDays: Bool, showTimeData: ShowTimeModel?) -> MonthItem {
        let month = self.yearItems[yearIndex].months[monthIndex]

        guard let cachedMonth = self.cachedMonths[month.id] else {
            DispatchQueue.global(qos: .userInteractive).async {
                let id = self.filledTimeMonth(
                    yearIndex: yearIndex,
                    monthIndex: monthIndex,
                    isDisablePreviousDays: isDisablePreviousDays,
                    showTimeData: showTimeData
                ).id

                DispatchQueue.main.async {
                    self.delegate?.monthFilled(id: id)
                }
            }

            return month
        }

        return cachedMonth
    }
}

private extension DeltaCalendarViewModel {

    func filledTimeMonth(yearIndex: Int, monthIndex: Int, isDisablePreviousDays: Bool, showTimeData: ShowTimeModel?)
    -> MonthItem {
        var month = self.yearItems[yearIndex].months[monthIndex]
        let daysRange = self.calendar.range(of: .day, in: .month, for: month.date)!
        let year = month.date.year(using: self.calendar)
        let monthVal = month.date.month(using: self.calendar)

        let days = self.days(
            with: daysRange,
            year: year,
            month: monthVal,
            isFillTime: true,
            isDisablePreviousDays: isDisablePreviousDays,
            showTimeData: showTimeData,
            endGapDate: nil
        )

        month.days = days

        self.cachedMonths[month.id] = month
        self.yearItems[yearIndex].months[monthIndex].days = days

        return month
    }

    // MARK: - Content creating logic

    func createContent(_ startData: StartModel) -> [YearItem] {
        guard startData.pickingYearData.from <= startData.pickingYearData.to else { return [] }

        let monthsText = DateFormatter().standaloneMonthSymbols!.map { $0.capitalized }
        let timeZone = self.timeFormatter.timeZone
        let today = Resources.today
        let todayMonth = today.month(using: self.calendar)
        let todayYear = today.year(using: self.calendar)

        let yearsRange = (startData.pickingYearData.from...startData.pickingYearData.to)
        let selectedDifYear = startData.pickingYearData.to - Resources.selectingYearGap
        let selectedYear = yearsRange.contains(selectedDifYear) ? selectedDifYear : startData.pickingYearData.from
        let endOrderDate = self.endOrderingDate(startData.orderGap)

        let years = yearsRange
            .map { DateComponents(calendar: self.calendar, timeZone: timeZone ,year: $0).date! }

        var items = years.map { year in
            let digitYear = year.year(using: self.calendar)
            let months = self.calendar.range(of: .month, in: .year, for: year)!

            let monthItems: [MonthItem] = months.map { month in
                let monthDate = DateComponents(
                    calendar: self.calendar,
                    timeZone: timeZone,
                    year: digitYear,
                    month: month
                ).date!

                let daysRange = self.calendar.range(of: .day, in: .month, for: monthDate)!
                let isFillingTime = digitYear == todayYear && todayMonth == month

                let days = self.days(
                    with: daysRange,
                    year: digitYear,
                    month: month,
                    isFillTime: isFillingTime,
                    isDisablePreviousDays: startData.isDisablePreviousDays,
                    showTimeData: startData.showTimeData,
                    endGapDate: endOrderDate
                )

                let title = monthsText[month - 1]
                let monthItem = MonthItem(title: title, date: monthDate, days: days)

                if isFillingTime {
                    self.cachedMonths[monthItem.id] = monthItem
                }

                return monthItem
            }

            let isSelected = digitYear == selectedYear

            return YearItem(value: digitYear, months: monthItems, isSelected: isSelected, isMock: false)
        }

        /// insert mock items for showing first and last collection cell at center.
        items.insert(.init(value: 0, months: [], isSelected: false, isMock: true), at: 0)
        items.append(.init(value: 0, months: [], isSelected: false, isMock: true))

        return items
    }

    func days(
        with data: Range<Int>,
        year: Int,
        month: Int,
        isFillTime: Bool,
        isDisablePreviousDays: Bool,
        showTimeData: ShowTimeModel?,
        endGapDate: Date?
    ) -> [DayItem] {
        let today = Resources.today

        let items = data.map {
            let dayDate = DateComponents(
                calendar: self.calendar,
                timeZone: self.timeFormatter.timeZone,
                year: year,
                month: month,
                day: $0
            ).date!

            let isSame = self.calendar.compare(dayDate, to: today, toGranularity: .day) == .orderedSame
            let description = isSame ? TextResources.today.capitalized : ""
            let weekday = self.calendar.component(.weekday, from: dayDate)

            lazy var dayTimeData: [DayTime] = self.dayTime(
                weekDay: weekday,
                day: $0,
                resource: showTimeData,
                endGapDate: endGapDate
            )

            let timesContent = isFillTime ? dayTimeData : []

            let dayData = Day(
                title: String($0),
                description: description,
                weekday: weekday,
                date: dayDate,
                timeData: timesContent
            )

            let isDisablePrev = isDisablePreviousDays &&
            self.calendar.compare(today, to: dayDate, toGranularity: .day) == .orderedDescending

            let isDisabled = isDisablePrev ? true : timesContent.isEmpty

            return DayItem(data: dayData, isDisabled: isDisabled, isSelected: false)
        }

        return self.addExtraEmptyDays(items)
    }

    func endOrderingDate(_ gap: OrderingGap?) -> Date? {
        guard let minutes = gap?.minutes else { return nil }

        return self.calendar.date(byAdding: .minute, value: minutes, to: Resources.today)
    }

    func isPastTime(at date: Date) -> Bool {
        let today = Resources.today

        guard self.calendar.compare(today, to: date, toGranularity: .day) == .orderedSame
        else { return false }

        let hoursResult = self.calendar.compare(today, to: date, toGranularity: .hour)

        guard hoursResult == .orderedSame else {
            return hoursResult == .orderedDescending ? true : false
        }

        let minResult = self.calendar.compare(today, to: date, toGranularity: .minute)

        switch minResult {
        case .orderedDescending, .orderedSame: return true
        case .orderedAscending:                return false
        }
    }

    func dayTime(weekDay: Int, day: Int, resource: ShowTimeModel?, endGapDate: Date?) -> [DayTime] {
        guard let resource, let dayData = resource.data.first(where: { $0.weekday == weekDay }) else { return [] }

        let startDate = DateComponents(
            calendar: self.calendar,
            timeZone: self.timeFormatter.timeZone,
            year: dayData.startDate.year(using: self.calendar),
            month: dayData.startDate.month(using: self.calendar),
            day: day,
            hour: dayData.startDate.hours(using: self.calendar),
            minute: dayData.startDate.minutes(using: self.calendar)
        )

        let endDate = DateComponents(
            calendar: self.calendar,
            timeZone: self.timeFormatter.timeZone,
            year: dayData.endDate.year(using: self.calendar),
            month: dayData.endDate.month(using: self.calendar),
            day: day,
            hour: dayData.endDate.hours(using: self.calendar),
            minute: dayData.endDate.minutes(using: self.calendar)
        )

        guard let startDate = startDate.date, let endDate = endDate.date else { return [] }

        var firstTime = startDate
        let firstMockItem = DayTime(value: Date(), isSelected: false, isMock: true)
        var timeData: [DayTime] = [firstMockItem]

        if !self.isPastTime(at: startDate), startDate.timeIntervalSince1970 > endGapDate?.timeIntervalSince1970 ?? 0 {
            timeData.append(.init(value: startDate, isSelected: true, isMock: false))
        }

        while firstTime < endDate {
            firstTime = firstTime.addingTimeInterval(Double(resource.offset) * 60.0)

            guard self.calendar.compare(firstTime, to: startDate, toGranularity: .day) == .orderedSame else { break }

            if let endGapDate, endGapDate.timeIntervalSince1970 > firstTime.timeIntervalSince1970 {
                continue
            }

            guard endDate.timeIntervalSince1970 > firstTime.timeIntervalSince1970 else { continue }

            if !self.isPastTime(at: firstTime) {
                let time = DayTime(value: firstTime, isSelected: false, isMock: false)
                timeData.append(time)
            }
        }

        guard timeData.count != 1 else { return [] }

        let lastMockItem = DayTime(value: Date(), isSelected: false, isMock: true)
        timeData.append(lastMockItem)

        return self.setStartSelectedDayTime(at: timeData)
    }

    func setStartSelectedDayTime(at times: [DayTime]) -> [DayTime] {
        guard let firstAvailableIndex = times.firstIndex(where: { !$0.isMock }) else { return times }

        var modifTimes = times
        modifTimes[firstAvailableIndex].isSelected = true

        return modifTimes
    }

    /// Adding empty days for right shifting.
    func addExtraEmptyDays(_ days: [DayItem]) -> [DayItem] {
        let firstWeekDayIndex = Resources.mondayIndex

        guard let first = days.first, first.data.weekday != firstWeekDayIndex
        else { return days }

        var currentDays = days

        let dif: Int = first.data.weekday >= firstWeekDayIndex ? (first.data.weekday - firstWeekDayIndex) :
        /// case when sunday is first day of month, at gregorian calendar index is 1.
        (Resources.weekdays.count - 1)

        (0..<dif).forEach { _ in
            let dayData = Day(title: "", description: "", weekday: 0, date: nil, timeData: [])
            let mockItem = DayItem(data: dayData, isDisabled: true, isSelected: false)

            currentDays.insert(mockItem, at: 0)
        }

        return currentDays
    }
}
