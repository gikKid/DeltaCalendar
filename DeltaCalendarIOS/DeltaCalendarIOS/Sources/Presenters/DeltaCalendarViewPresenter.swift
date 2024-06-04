import Foundation
import Combine

final class DeltaCalendarViewPresenter: DeltaCalendarViewPresentable {

	@Published private(set) var selectedData: DCSelectedModel?
	@Published private(set) var currentMonthIndex: IndexPath
	private(set) var currentYearIndex: Int = 0
	weak var viewModel: DeltaCalendarViewModelProtocol?
	weak var dataSource: DataSource?

	public var monthIndexPublisher: AnyPublisher<IndexPath, Never> {
		self.$currentMonthIndex.eraseToAnyPublisher()
	}
	public var selectedDatePublisher: AnyPublisher<Date?, Never> {
		self.$selectedData.map {
			guard let yearIndex = $0?.yearIndex, let monthIndex = $0?.monthIndex,
				  let dayIndex = $0?.dayIndex, let data = self.viewModel?.data,
				  let day = data[yearIndex].months[monthIndex].days[dayIndex].data.date
			else { return nil }

			return day
		}.eraseToAnyPublisher()
	}

	// MARK: - Setting methods

	init(_ dataSource: DataSource,_ viewModel: DeltaCalendarViewModelProtocol) {
		self.dataSource = dataSource
		self.viewModel = viewModel
		self.currentMonthIndex = .init(row: 0, section: DCalendarSection.month.rawValue)
	}

	func setupDS(with completion: @escaping () -> Void) {
		guard var snapshot = self.dataSource?.snapshot() else { return }

		snapshot.appendSections([.month])

		self.dataSource?.apply(snapshot, animatingDifferences: false)

		var monthSectionSnapshot = DCSectionSnapshot()

		let ids = self.viewModel?.data[self.currentYearIndex].months.map { $0.id } ?? []
		monthSectionSnapshot.append(ids)

		self.dataSource?.apply(monthSectionSnapshot, to: .month, animatingDifferences: false,
						 completion: completion)
	}

	func updateDaySelecting(at dayIndex: Int) {
		if let selectedData = self.selectedData {
			let unselectModel = DCSelectedModel(yearIndex: selectedData.yearIndex,
												monthIndex: selectedData.monthIndex,
												dayIndex: selectedData.dayIndex)

			self.viewModel?.toggleSelecting(at: unselectModel)
		}

		let selectModel = DCSelectedModel(yearIndex: self.currentYearIndex,
										  monthIndex: self.currentMonthIndex.row, dayIndex: dayIndex)

		self.viewModel?.toggleSelecting(at: selectModel)

		self.setSelectedDate(by: dayIndex)
	}

	func makeNextMonth() {
		let nextMonth = self.currentMonthIndex.row + 1

		guard nextMonth <= DCResources.monthCount - 1 else {
			self.configureNextYear(); return
		}

		self.currentMonthIndex.row = nextMonth
	}

	func makePrevMonth() {
		let prevMonth = self.currentMonthIndex.row - 1

		guard prevMonth >= 0 else {
			self.configurePrevYear(); return
		}

		self.currentMonthIndex.row = prevMonth
	}

	func itemScrolled(currentItem: IndexPath) {
		guard let section = self.section(index: currentItem)
		else { return }

		self.onItemScrolled(currentIndex: currentItem, section: section)
	}

	// MARK: - Getting methods

	func currentMonth() -> IndexPath? {
		let now = Date()
		let month = now.month()

		guard let monthSection = self.dataSource?.snapshot().indexOfSection(.month)
		else { return nil }

		return IndexPath(item: month - 1, section: monthSection)
	}

	func month(at index: Int) -> DCalendarMonthItem? {
		guard let data = self.viewModel?.data else { return nil }

		return data[self.currentYearIndex].months[index]
	}

	func monthTitle() -> String {
		guard let data = self.viewModel?.data else { return "-" }

		return data[self.currentYearIndex].months[self.currentMonthIndex.row].title
	}
}

private extension DeltaCalendarViewPresenter {

	func setSelectedDate(by dayIndex: Int) {
		self.selectedData = .init(yearIndex: self.currentYearIndex,
								  monthIndex: self.currentMonthIndex.row,
								  dayIndex: dayIndex)
	}

	// MARK: - Configuring sections

	func configureNextYear() {
		guard let data = self.viewModel?.data, self.currentYearIndex < data.count - 1
		else { return }

		self.currentYearIndex += 1
		self.currentMonthIndex.row = 0

		self.selectedData = nil

		self.reconfigureMonths()
	}

	func configurePrevYear() {
		guard self.currentYearIndex != 0 else { return }

		self.currentYearIndex -= 1
		self.currentMonthIndex.row = DCResources.monthCount - 1

		self.selectedData = nil

		self.reconfigureMonths()
	}

	func reconfigureMonths() {
		guard let data = self.viewModel?.data else { return }

		let ids = data[self.currentYearIndex].months.map { $0.id }
		var sectionSnapshot = DCSectionSnapshot()
		sectionSnapshot.append(ids)

		self.dataSource?.apply(sectionSnapshot, to: .month, animatingDifferences: true)
	}

	// MARK: - Scrolling logic

	func onItemScrolled(currentIndex: IndexPath, section: DCalendarSection) {

		switch section {
		case .month:
			self.monthScrolled(to: currentIndex.row)
		}
	}

	func monthScrolled(to index: Int) {
		self.currentMonthIndex.row = index
		self.reloadSections(sections: [.month], animated: true)
	}

	// MARK: - Section managing

	func reloadSections(sections: [DCalendarSection], animated: Bool) {
		guard var snapshot = self.dataSource?.snapshot() else { return }

		if #available(iOS 15, *) {
			self.dataSource?.applySnapshotUsingReloadData(snapshot)
		} else {
			snapshot.reloadSections(sections)
			self.dataSource?.apply(snapshot, animatingDifferences: animated)
		}
	}

	func section(index: IndexPath) -> DCalendarSection? {
		if #available(iOS 15, *) {
			guard let section = self.dataSource?.sectionIdentifier(for: index.section)
			else { return nil }

			return section
		} else {
			guard let itemID = self.dataSource?.itemIdentifier(for: index),
				  let section = self.dataSource?.snapshot().sectionIdentifier(containingItem: itemID)
			else { return nil }

			return section
		}
	}
}
