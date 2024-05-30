import Foundation

final class DeltaCalendarViewModel: NSObject {

	private(set) var isShowYear: Bool = false
	private(set) var isShowTime: Bool = false
	private(set) var theme: DCalendarTheme = .light
	private var currentYearIndex: Int = 0
	private let data: [DCalendarYearItem]

	override init() {

		let calendar = Calendar.current

		let now = Date()
		let startYear = now.year(using: calendar)
		let monthsText = DateFormatter().monthSymbols!
		let years = (startYear...DCResources.maxYear).map {
			DateComponents(calendar: calendar, year: $0).date!
		}

		self.data = years.map { year in

			let digitYear = year.year()

			let months = calendar.range(of: .month, in: .year, for: year)!

			let monthItems: [DCalendarMonthItem] = months.map { month in

				let monthDate = DateComponents(calendar: calendar, year: digitYear, month: month).date!

				let daysRange = calendar.range(of: .day, in: .month, for: monthDate)!

				let days = daysRange.map {
					let dayDate = DateComponents(calendar: calendar, year: digitYear, month: month, day: $0).date!
					let description = now == dayDate ? DCTextResources.today : ""

					return DeltaCalendarDay(title: String($0), description: description)
				}

				let title = monthsText[month - 1]
				return DCalendarMonthItem(title: title, days: days)
			}

			return .init(title: String(digitYear), months: monthItems)
		}
	}

	func update(theme: DCalendarTheme, isShowYear: Bool, isShowTime: Bool) {
		self.theme = theme
		self.isShowYear = isShowYear
		self.isShowTime = isShowTime
	}

	func section(at index: Int) -> DCalendarSection? {
		DCalendarSection(section: index, isShowYear: self.isShowYear,
						 isShowTime: self.isShowTime)
	}

	func month(at index: Int) -> DCalendarMonthItem {
		self.data[self.currentYearIndex].months[index]
	}
}
