import Foundation
import Combine

final class DeltaCalendarViewModel: NSObject {

	typealias DS = DeltaCalendarView.DeltaCalendarDataSource

	private var data: [DCalendarYearItem] = []
	private(set) var startData: DCStartModel
	private var currentYearIndex: Int = 0
	@Published private var currentMonthIndex: IndexPath
	public var monthIndexPublisher: AnyPublisher<IndexPath, Never> {
		self.$currentMonthIndex.eraseToAnyPublisher()
	}

	// MARK: - Setup logic

	init(theme: DeltaCalendarTheme, isShowTime: Bool, isWeekendsDisabled: Bool) {
		self.startData = .init(theme: theme, isWeekendsDisabled: isWeekendsDisabled,
							   isShowTime: isShowTime)

		self.currentMonthIndex = .init(row: 0, section: DCalendarSection.month.rawValue)

		super.init()

		self.data = self.createContent()
	}

	func setupDataSource(at dataSource: DS, with completion: @escaping () -> Void) {

		var snapshot = dataSource.snapshot()
		snapshot.appendSections([.month])

		dataSource.apply(snapshot, animatingDifferences: false)

		var daysSectionSnapshot = DCSectionSnapshot()

		let ids = self.data[self.currentYearIndex].months.map { $0.id }
		daysSectionSnapshot.append(ids)

		dataSource.apply(daysSectionSnapshot, to: .month, animatingDifferences: false,
						 completion: completion)
	}

	func itemScrolled(currentItem: IndexPath, at dataSource: DS) {
		guard let section = self.section(index: currentItem, at: dataSource)
		else { return }

		self.onItemScrolled(currentIndex: currentItem, section: section, at: dataSource)
	}

	func makePrevMonth(at dataSource: DS) {

		let prevMonth = self.currentMonthIndex.row - 1

		guard prevMonth > 0 else {
			// FIXME: Show prev year if it possible
			return
		}

		self.currentMonthIndex.row = prevMonth
	}

	func makeNextMonth(at dataSource: DS) {

		let nextMonth = self.currentMonthIndex.row + 1

		guard nextMonth <= self.data[self.currentYearIndex].months.count - 1 else {
			// FIXME: Show next year if it possible
			return
		}

		self.currentMonthIndex.row = nextMonth
	}

	// MARK: - Getting logic

//	func section(at index: Int) -> DCalendarSection? {
//		DCalendarSection(section: index, isShowYear: self.isShowYear,
//						 isShowTime: self.isShowTime)
//	}

	func month(at index: Int) -> DCalendarMonthItem {
		self.data[self.currentYearIndex].months[index]
	}

	func monthTitle(at dataSource: DS) -> String {
		self.data[self.currentYearIndex].months[self.currentMonthIndex.row].title
	}

	func currentMonth(at dataSource: DS) -> IndexPath? {
		let now = Date()
		let month = now.month()

		guard let monthSection = dataSource.snapshot().indexOfSection(.month)
		else { return nil }

		return IndexPath(item: month - 1, section: monthSection)
	}
}

private extension DeltaCalendarViewModel {

	func onItemScrolled(currentIndex: IndexPath, section: DCalendarSection, at dataSource: DS) {

		switch section {
		case .month:
			self.monthScrolled(to: currentIndex.row, at: dataSource)
		}
	}

	func monthScrolled(to index: Int, at dataSource: DS) {
		self.currentMonthIndex.row = index
		self.reloadSections(sections: [.month], animated: false, at: dataSource)
	}

	func reloadSections(sections: [DCalendarSection], animated: Bool, at dataSource: DS) {
		var snapshot = dataSource.snapshot()

		if #available(iOS 15, *) {
			dataSource.applySnapshotUsingReloadData(snapshot)
		} else {
			snapshot.reloadSections(sections)
			dataSource.apply(snapshot, animatingDifferences: animated)
		}
	}

	func section(index: IndexPath, at dataSource: DS) -> DCalendarSection? {
		if #available(iOS 15, *) {
			guard let section = dataSource.sectionIdentifier(for: index.section)
			else { return nil }

			return section
		} else {
			guard let itemID = dataSource.itemIdentifier(for: index),
				  let section = dataSource.snapshot().sectionIdentifier(containingItem: itemID)
			else { return nil }

			return section
		}
	}

	func createContent() -> [DCalendarYearItem] {
		let calendar = Calendar.current

		let now = Date()
		let startYear = now.year(using: calendar)
		let monthsText = DateFormatter().monthSymbols!

		let years = (startYear...DCResources.maxYear)
			.map { DateComponents(calendar: calendar, year: $0).date! }

		return years.map { year in

			let digitYear = year.year()

			let months = calendar.range(of: .month, in: .year, for: year)!

			let monthItems: [DCalendarMonthItem] = months.map { month in

				let monthDate = DateComponents(calendar: calendar, year: digitYear, month: month).date!

				let daysRange = calendar.range(of: .day, in: .month, for: monthDate)!

				let days = daysRange.map {
					let dayDate = DateComponents(calendar: calendar, year: digitYear, month: month, day: $0).date!
					let description = now == dayDate ? DCTextResources.today : ""
					let weekday = calendar.component(.weekday, from: dayDate)

					return DeltaCalendarDay(title: String($0), description: description, weekday: weekday)
				}

				let title = monthsText[month - 1]
				return DCalendarMonthItem(title: title, days: days, isWeekendsDisabled: self.startData.isWeekendsDisabled)
			}

			return .init(title: String(digitYear), months: monthItems)
		}
	}
}
