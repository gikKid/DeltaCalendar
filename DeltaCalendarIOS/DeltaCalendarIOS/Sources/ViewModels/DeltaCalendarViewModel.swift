import Foundation
import Combine

internal protocol DeltaCalendarViewModelProtocol: AnyObject {

	var data: [YearItem] { get }

	func toggleSelecting(at date: SelectedModel)
}

internal final class DeltaCalendarViewModel: DeltaCalendarViewModelProtocol {

	private let calendar = Calendar.current
	private(set) var data: [YearItem] = []
	private let defMaxYear: Int = Resources.maxYear
	private lazy var defStartYear: Int = {
		Date().year(using: self.calendar)
	}()

	init(with data: StartModel) {

		let startYear = data.pickingYearData?.from ?? self.defStartYear
		let endYear = data.pickingYearData?.to ?? self.defMaxYear

		self.data = self.createContent(from: startYear, to: endYear, startData: data)
	}

	func toggleSelecting(at date: SelectedModel) {
		self.data[date.yearIndex].months[date.monthIndex].days[date.dayIndex]
			.isSelected.toggle()
	}
}

private extension DeltaCalendarViewModel {

	// MARK: - Content creating logic

	func createContent(from: Int, to: Int, startData: StartModel) -> [YearItem] {

		guard from <= to else { return [] }

		let monthsText = DateFormatter().monthSymbols!

		let years = (from...to)
			.map { DateComponents(calendar: self.calendar, year: $0).date! }

		return years.map { year in

			let digitYear = year.year()

			let months = self.calendar.range(of: .month, in: .year, for: year)!

			let monthItems: [MonthItem] = months.map { month in

				let monthDate = DateComponents(calendar: self.calendar, year: digitYear, month: month).date!

				let daysRange = self.calendar.range(of: .day, in: .month, for: monthDate)!
				let days = self.days(with: daysRange, year: digitYear, month: month, startData: startData)

				let monthTitle = monthsText[month - 1]
				let title = startData.pickingYearData != nil ? monthTitle :
				"\(monthTitle) \(digitYear)"

				return MonthItem(title: title, days: days)
			}

			return .init(value: digitYear, months: monthItems, isSelected: false)
		}
	}

	func days(with data: Range<Int>, year: Int, month: Int, startData: StartModel) -> [DayItem] {

		let today = Date()

		let items = data.map {
			let dayDate = DateComponents(calendar: calendar, year: year, month: month, day: $0).date!
			let isSame = self.calendar.compare(dayDate, to: today, toGranularity: .day) == .orderedSame
			let description = isSame ? TextResources.today : ""
			let weekday = self.calendar.component(.weekday, from: dayDate)

			let dayData = Day(title: String($0), description: description, 
										   weekday: weekday, date: dayDate)


			let isDisabled = (startData.weekendsOff && self.isWeekday(at: dayDate)) ||
			(startData.pastDaysOff && self.isPastDay(at: dayDate))

			let colors = DayColors(theme: startData.theme)

			return DayItem(data: dayData, colors: colors, isDisabled: isDisabled)
		}

		return self.addExtraEmptyDays(items, startData.theme)
	}

	func isWeekday(at date: Date) -> Bool {
		let weekday = self.calendar.component(.weekday, from: date)
		return Resources.weekends.contains(weekday)
	}

	func isPastDay(at date: Date) -> Bool {
		self.calendar.compare(Date(), to: date, toGranularity: .day) == .orderedDescending
	}

	/// Adding empty days for right shifting.
	func addExtraEmptyDays(_ days: [DayItem],_ theme: Theme) -> [DayItem] {

		let firstWeekDayIndex = Resources.mondayIndex

		guard let first = days.first, first.data.weekday != firstWeekDayIndex
		else { return days }

		var currentDays = days

		let dif: Int = first.data.weekday >= firstWeekDayIndex ? (first.data.weekday - firstWeekDayIndex) :
		(Resources.weekdays.count - 1) /// case when sunday is first day of month, at gregorian calendar index is 1.

		(0..<dif).forEach { _ in
			let dayData = Day(title: "", description: "", weekday: 0, date: nil)
			let colors = DayColors(theme: theme)

			currentDays.insert(.init(data: dayData, colors: colors, isDisabled: true), at: 0)
		}

		return currentDays
	}
}
