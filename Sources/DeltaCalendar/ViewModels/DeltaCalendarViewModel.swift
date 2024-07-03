import Foundation
import Combine

internal protocol DeltaCalendarViewModelProtocol: AnyObject {

	var data: [YearItem] { get }

	func toggleSelecting(at date: SelectedModel)
	func toggleYearSelecting(_ data: UpdateSelectingModel)
	func date(selectedData: SelectedModel, timeIndex: Int) -> Date?
}

internal final class DeltaCalendarViewModel: DeltaCalendarViewModelProtocol {

	private let timeFormatter = DateFormatter.build(format: Resources.timeFormat)
	private(set) var data: [YearItem] = []

	init(with data: StartModel) {
		self.data = self.createContent(data)
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
}

private extension DeltaCalendarViewModel {

	// MARK: - Content creating logic

	func createContent(_ startData: StartModel) -> [YearItem] {

        guard startData.pickingYearData.from <= startData.pickingYearData.to else { return [] }

		let monthsText = DateFormatter().monthSymbols!
		let calendar = self.timeFormatter.calendar ?? .current
		let timeZone = self.timeFormatter.timeZone

        let yearsRange = (startData.pickingYearData.from...startData.pickingYearData.to)
        let selectedDifYear = startData.pickingYearData.to - Resources.selectingYearGap
        let selectedYear = yearsRange.contains(selectedDifYear) ? selectedDifYear : startData.pickingYearData.from

		let years = yearsRange
			.map { DateComponents(calendar: calendar, timeZone: timeZone ,year: $0).date! }

		var items = years.map { year in

			let digitYear = year.year()

			let months = calendar.range(of: .month, in: .year, for: year)!

			let monthItems: [MonthItem] = months.map { month in

				let monthDate = DateComponents(calendar: calendar, timeZone: timeZone,
											   year: digitYear, month: month).date!

				let daysRange = calendar.range(of: .day, in: .month, for: monthDate)!
				let days = self.days(with: daysRange, year: digitYear, month: month, startData: startData)

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

	func days(with data: Range<Int>, year: Int, month: Int, startData: StartModel) -> [DayItem] {

		let today = Date()
		let calendar = self.timeFormatter.calendar ?? .current
		let timeZone = self.timeFormatter.timeZone

		let items = data.map {

			let dayDate = DateComponents(calendar: calendar, timeZone: timeZone,
										 year: year, month: month, day: $0).date!

			let isSame = calendar.compare(dayDate, to: today, toGranularity: .day) == .orderedSame
			let description = isSame ? TextResources.today.capitalized : ""
			let weekday = calendar.component(.weekday, from: dayDate)

			let timeData: [DayTime] = self.dayTime(weekDay: weekday, resource: startData.showTimeData)

			let dayData = Day(title: String($0), description: description, weekday: weekday,
                              date: dayDate, timeData: timeData)

			let isDisabled = timeData.isEmpty

            return DayItem(data: dayData, isDisabled: isDisabled, isSelected: isSame)
		}

		return self.addExtraEmptyDays(items)
	}

	func isWeekday(at date: Date) -> Bool {
		let calendar = self.timeFormatter.calendar ?? .current
		let weekday = calendar.component(.weekday, from: date)

		return Resources.weekends.contains(weekday)
	}

	func isPastDay(at date: Date) -> Bool {
		let calendar = self.timeFormatter.calendar ?? .current
		return calendar.compare(Date(), to: date, toGranularity: .day) == .orderedDescending
	}

	func dayTime(weekDay: Int, resource: ShowTimeModel) -> [DayTime] {
		guard let dayData = resource.data.first(where: { $0.weekday == weekDay })
		else { return [] }

		var firstTime = dayData.startDate
		let firstMockTime = DayTime(value: Date(), isSelected: false, isMock: true)
		let startDate = DayTime(value: firstTime, isSelected: true, isMock: false)

		var timeData: [DayTime] = [firstMockTime, startDate]

		while firstTime < dayData.endDate {
			firstTime = firstTime.addingTimeInterval(Double(resource.offset) * 60.0)
			let time = DayTime(value: firstTime, isSelected: false, isMock: false)
			timeData.append(time)
		}

		let lastMockItem = DayTime(value: Date(), isSelected: false, isMock: true)
		timeData.append(lastMockItem)

		return timeData
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
