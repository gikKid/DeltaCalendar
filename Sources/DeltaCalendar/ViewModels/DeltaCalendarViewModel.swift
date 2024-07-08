import Foundation
import Combine

internal protocol DeltaCalendarViewModelDelegate: AnyObject {
    func calendarConfigured()
}

internal protocol DeltaCalendarViewModelProtocol: AnyObject {

    var delegate: DeltaCalendarViewModelDelegate? { get set }
    var data: [YearItem] { get }

    func isConfiguring() -> Bool
    func toggleSelecting(at date: SelectedModel)
    func toggleYearSelecting(_ data: UpdateSelectingModel)
    func date(selectedData: SelectedModel, timeIndex: Int) -> Date?
}

internal final class DeltaCalendarViewModel: DeltaCalendarViewModelProtocol {

    public weak var delegate: DeltaCalendarViewModelDelegate?
    private let timeFormatter = DateFormatter.build(format: Resources.timeFormat)
    private(set) var data: [YearItem] = YearItem.mockData()

    private var calendar: Calendar {
        self.timeFormatter.calendar ?? .current
    }

    init(with data: StartModel) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.data = self.createContent(data)

            DispatchQueue.main.async {
                self.delegate?.calendarConfigured()
            }
        }
    }

    func toggleSelecting(at date: SelectedModel) {
        self.data[date.yearIndex].months[date.monthIndex].days[date.dayIndex]
            .isSelected.toggle()
    }

    func toggleYearSelecting(_ data: UpdateSelectingModel) {
        self.data[data.prevIndex].isSelected.toggle()
        self.data[data.index].isSelected.toggle()
    }

    func date(selectedData: SelectedModel, timeIndex: Int) -> Date? {

        let day = self.data[selectedData.yearIndex].months[selectedData.monthIndex]
            .days[selectedData.dayIndex].data
        let time = day.timeData[timeIndex].title

        guard let date = day.date else { return nil }

        let dayText = DateFormatter.build(format: Resources.isoFormat).string(from: date)

        return DateFormatter.build(format: Resources.dateFormat).date(from: "\(dayText) \(time)")
    }

    func isConfiguring() -> Bool {
        guard let year = self.data.first else {
            fatalError(CalendarError.dataConfiguring.description)
        }

        guard !year.isMock else { return false }

        return year.months.count < Resources.monthCount
    }
}

private extension DeltaCalendarViewModel {

    // MARK: - Content creating logic

    func createContent(_ startData: StartModel) -> [YearItem] {

        guard startData.pickingYearData.from <= startData.pickingYearData.to else { return [] }

        let monthsText = DateFormatter().monthSymbols!
        let timeZone = self.timeFormatter.timeZone

        let yearsRange = (startData.pickingYearData.from...startData.pickingYearData.to)
        let selectedDifYear = startData.pickingYearData.to - Resources.selectingYearGap
        let selectedYear = yearsRange.contains(selectedDifYear) ? selectedDifYear : startData.pickingYearData.from
        let endOrderDate = self.endOrderingDate(startData.orderGap)

        let years = yearsRange
            .map { DateComponents(calendar: self.calendar, timeZone: timeZone ,year: $0).date! }

        var items = years.map { year in

            let digitYear = year.year()

            let months = self.calendar.range(of: .month, in: .year, for: year)!

            let monthItems: [MonthItem] = months.map { month in

                let monthDate = DateComponents(calendar: self.calendar, timeZone: timeZone,
                                               year: digitYear, month: month).date!

                let daysRange = self.calendar.range(of: .day, in: .month, for: monthDate)!

                let days = self.days(with: daysRange, year: digitYear, month: month, startData: startData,
                                     endGapDate: endOrderDate)

                let title = monthsText[month - 1]

                return MonthItem(title: title, days: days)
            }

            let isSelected = digitYear == selectedYear

            return YearItem(value: digitYear, months: monthItems, isSelected: isSelected, isMock: false)
        }

        /// insert mock items for showing first and last collection cell at center.
        items.insert(.init(value: 0, months: [], isSelected: false, isMock: true), at: 0)
        items.append(.init(value: 0, months: [], isSelected: false, isMock: true))

        return items
    }

    func days(with data: Range<Int>, year: Int, month: Int, startData: StartModel, endGapDate: Date?) -> [DayItem] {
        let today = Resources.today

        let items = data.map {

            let dayDate = DateComponents(calendar: self.calendar, timeZone: self.timeFormatter.timeZone,
                                         year: year, month: month, day: $0).date!

            let isSame = self.calendar.compare(dayDate, to: today, toGranularity: .day) == .orderedSame
            let description = isSame ? TextResources.today.capitalized : ""
            let weekday = self.calendar.component(.weekday, from: dayDate)

            let timeData: [DayTime] = self.dayTime(weekDay: weekday, day: $0, resource: startData.showTimeData,
                                                   endGapDate: endGapDate)

            let dayData = Day(title: String($0), description: description, weekday: weekday,
                              date: dayDate, timeData: timeData)

            let isDisablePrev = startData.disablePreviousDays &&
            self.calendar.compare(today, to: dayDate, toGranularity: .day) == .orderedDescending

            let isDisabled = isDisablePrev ? true : timeData.isEmpty

            return DayItem(data: dayData, isDisabled: isDisabled, isSelected: isSame)
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

    func dayTime(weekDay: Int, day: Int, resource: ShowTimeModel, endGapDate: Date?) -> [DayTime] {
        guard let dayData = resource.data.first(where: { $0.weekday == weekDay })
        else { return [] }

        let startDate = DateComponents(calendar: self.calendar, year: dayData.startDate.year(),
                                       month: dayData.startDate.month(), day: day, hour: dayData.startDate.hours(),
                                       minute: dayData.startDate.minutes())

        let endDate = DateComponents(calendar: self.calendar, year: dayData.endDate.year(),
                                     month: dayData.endDate.month(), day: day, hour: dayData.endDate.hours(),
                                     minute: dayData.endDate.minutes())

        guard let startDate = startDate.date, let endDate = endDate.date else { return [] }

        var firstTime = startDate
        let firstMockItem = DayTime(value: Date(), isSelected: false, isMock: true)
        var timeData: [DayTime] = [firstMockItem]

        if !self.isPastTime(at: startDate), startDate.timeIntervalSince1970 > endGapDate?.timeIntervalSince1970 ?? 0 {
            timeData.append(.init(value: startDate, isSelected: true, isMock: false))
        }

        while firstTime < endDate {
            firstTime = firstTime.addingTimeInterval(Double(resource.offset) * 60.0)

            if let endGapDate, endGapDate.timeIntervalSince1970 > firstTime.timeIntervalSince1970 {
                continue
            }

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
        (Resources.weekdays.count - 1) /// case when sunday is first day of month, at gregorian calendar index is 1.

        (0..<dif).forEach { _ in
            let dayData = Day(title: "", description: "", weekday: 0, date: nil, timeData: [])
            let mockItem = DayItem(data: dayData, isDisabled: true, isSelected: false)

            currentDays.insert(mockItem, at: 0)
        }

        return currentDays
    }
}
