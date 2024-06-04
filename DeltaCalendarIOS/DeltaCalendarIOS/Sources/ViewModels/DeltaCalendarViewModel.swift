import Foundation
import Combine

protocol DeltaCalendarViewModelProtocol: AnyObject {
	
	var data: [DCalendarYearItem] { get }

	func toggleSelecting(at date: DCSelectedModel)
}

final class DeltaCalendarViewModel: DeltaCalendarViewModelProtocol {

	private let calendar = Calendar.current
	private(set) var data: [DCalendarYearItem] = []
	private(set) var startData: DCStartModel

	init(with data: DCStartModel) {
		self.startData = data
		self.data = self.createContent()
	}

	func toggleSelecting(at date: DCSelectedModel) {
		self.data[date.yearIndex].months[date.monthIndex].days[date.dayIndex]
			.isSelected.toggle()
	}

//	func section(at index: Int) -> DCalendarSection? {
//		DCalendarSection(section: index, isShowYear: self.isShowYear,
//						 isShowTime: self.isShowTime)
//	}
}

private extension DeltaCalendarViewModel {

	// MARK: - Content creating logic

	func createContent() -> [DCalendarYearItem] {

		let now = Date()
		let startYear = now.year(using: self.calendar)
		let monthsText = DateFormatter().monthSymbols!

		let years = (startYear...DCResources.maxYear)
			.map { DateComponents(calendar: self.calendar, year: $0).date! }

		return years.map { year in

			let digitYear = year.year()

			let months = self.calendar.range(of: .month, in: .year, for: year)!

			let monthItems: [DCalendarMonthItem] = months.map { month in

				let monthDate = DateComponents(calendar: self.calendar, year: digitYear, month: month).date!

				let daysRange = self.calendar.range(of: .day, in: .month, for: monthDate)!
				let days = self.days(with: daysRange, year: digitYear, month: month, calendar: self.calendar)

				let monthTitle = monthsText[month - 1]
				let title = self.startData.isPickingYear ? monthTitle : "\(monthTitle) \(digitYear)"

				return DCalendarMonthItem(title: title, days: days)
			}

			return .init(value: digitYear, months: monthItems)
		}
	}

	func days(with data: Range<Int>, year: Int, month: Int, calendar: Calendar = .current) -> [DCalendarDayItem] {

		let today = Date()

		let items = data.map {
			let dayDate = DateComponents(calendar: calendar, year: year, month: month, day: $0).date!
			let description = today == dayDate ? DCTextResources.today : ""
			let weekday = calendar.component(.weekday, from: dayDate)

			let dayData = DeltaCalendarDay(title: String($0), description: description, 
										   weekday: weekday, date: dayDate)

			let isWeekDay = DCResources.weekends.contains(weekday)
			let isDisabled = isWeekDay && self.startData.isWeekendsDisabled
			let colors = DCalendarDayColors(theme: self.startData.theme)

			return DCalendarDayItem(data: dayData, colors: colors, isDisabled: isDisabled)
		}

		return self.addExtraEmptyDays(items)
	}

	/// Adding empty days for right shifting.
	func addExtraEmptyDays(_ days: [DCalendarDayItem]) -> [DCalendarDayItem] {

		let firstWeekDayIndex = DCResources.mondayIndex

		guard let first = days.first, first.data.weekday != firstWeekDayIndex
		else { return days }

		var currentDays = days

		let dif: Int = first.data.weekday >= firstWeekDayIndex ? (first.data.weekday - firstWeekDayIndex) :
		(DCResources.weekdays.count - 1) /// case when sunday is first day of month, at gregorian calendar index is 1.

		(0..<dif).forEach { _ in
			let dayData = DeltaCalendarDay(title: "", description: "", weekday: 0, date: nil)
			let colors = DCalendarDayColors(theme: self.startData.theme)

			currentDays.insert(.init(data: dayData, colors: colors, isDisabled: true), at: 0)
		}

		return currentDays
	}
}
