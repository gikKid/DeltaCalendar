import Foundation
import Combine

internal final class DeltaCalendarViewPresenter: DeltaCalendarViewPresentable {

	@Published private(set) var selectedData: SelectedModel?
	@Published private(set) var currentMonthIndex: Int = 0
	private(set) var currentYearIndex: Int = 0
	private(set) var yearsItem: YearsItem?
	weak var viewModel: DeltaCalendarViewModelProtocol?
	weak var dataSource: DataSource?

	public var monthIndexPublisher: AnyPublisher<Int, Never> {
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

	init(_ dataSource: DataSource, _ viewModel: DeltaCalendarViewModelProtocol) {
		self.dataSource = dataSource
		self.viewModel = viewModel
	}

	func setupDS(with startData: StartModel) {
		guard var snapshot = self.dataSource?.snapshot() else { return }

		var sections: [Section] = [.month]

		let isShowYearsSection = startData.pickingYearData != nil

		isShowYearsSection ? sections.insert(.year, at: 0) : ()

		snapshot.appendSections(sections)

		self.dataSource?.apply(snapshot, animatingDifferences: false)

		isShowYearsSection ? self.configureYearsSection() : ()

		self.reconfigureMonths(animated: false)
	}

	// MARK: - Updating state methods

	func updateDaySelecting(at dayIndex: Int) {
		if let selectedData = self.selectedData {
			let unselectModel = SelectedModel(yearIndex: selectedData.yearIndex,
											  monthIndex: selectedData.monthIndex,
											  dayIndex: selectedData.dayIndex)

			self.viewModel?.toggleSelecting(at: unselectModel)
		}

		let selectModel = SelectedModel(yearIndex: self.currentYearIndex,
										monthIndex: self.currentMonthIndex,
										dayIndex: dayIndex)

		self.viewModel?.toggleSelecting(at: selectModel)

		self.setSelectedDate(by: dayIndex)
	}

	func makeNextMonth() {
		let nextMonth = self.currentMonthIndex + 1

		guard nextMonth <= Resources.monthCount - 1 else {
			self.configureNextYear(); return
		}

		self.currentMonthIndex = nextMonth
	}

	func makePrevMonth() {
		let prevMonth = self.currentMonthIndex - 1

		guard prevMonth >= 0 else {
			self.configurePrevYear(); return
		}

		self.currentMonthIndex = prevMonth
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

	func month(at index: Int) -> MonthItem? {
		guard let data = self.viewModel?.data else { return nil }

		return data[self.currentYearIndex].months[index]
	}

	func monthTitle() -> String {
		guard let data = self.viewModel?.data else { return "-" }

		return data[self.currentYearIndex].months[self.currentMonthIndex].title
	}

	func section(at index: Int, startData: StartModel) -> Section? {
		let isShowYear = startData.pickingYearData != nil
		let isShowTime = startData.showTimeData != nil

		return Section(section: index, isShowYear: isShowYear, isShowTime: isShowTime)
	}
}

private extension DeltaCalendarViewPresenter {

	func setSelectedDate(by dayIndex: Int) {
		self.selectedData = .init(yearIndex: self.currentYearIndex,
								  monthIndex: self.currentMonthIndex,
								  dayIndex: dayIndex)
	}

	// MARK: - Configuring sections

	func configureYearsSection() {
		guard let data = self.viewModel?.data else { return }

		self.yearsItem = .init(data: data)

		guard let id = self.yearsItem?.id else { return }

		var sectionSnapshot = SectionSnapshot()
		sectionSnapshot.append([id])

		self.dataSource?.apply(sectionSnapshot, to: .year, animatingDifferences: false)
	}

	func configureNextYear() {
		guard let data = self.viewModel?.data, self.currentYearIndex < data.count - 1
		else { return }

		self.currentYearIndex += 1
		self.currentMonthIndex = 0

		self.selectedData = nil

		self.reconfigureMonths(animated: true)
	}

	func configurePrevYear() {
		guard self.currentYearIndex != 0 else { return }

		self.currentYearIndex -= 1
		self.currentMonthIndex = Resources.monthCount - 1

		self.selectedData = nil

		self.reconfigureMonths(animated: true)
	}

	func reconfigureMonths(animated: Bool) {
		guard let data = self.viewModel?.data else { return }

		let ids = data[self.currentYearIndex].months.map { $0.id }
		var sectionSnapshot = SectionSnapshot()
		sectionSnapshot.append(ids)

		self.dataSource?.apply(sectionSnapshot, to: .month, animatingDifferences: animated)
	}

	// MARK: - Scrolling logic

	func onItemScrolled(currentIndex: IndexPath, section: Section) {

		let index = currentIndex.row

		switch section {
		case .year: self.yearScrolled(to: index)
		case .month: self.monthScrolled(to: index)
		}
	}

	func monthScrolled(to index: Int) {
		self.currentMonthIndex = index
		self.reloadSections(sections: [.month])
	}

	func yearScrolled(to index: Int) {

	}

	// MARK: - Section managing

	func reloadSections(sections: [Section]) {
		guard var snapshot = self.dataSource?.snapshot() else { return }

		if #available(iOS 15, *) {
			self.dataSource?.applySnapshotUsingReloadData(snapshot)
		} else {
			snapshot.reloadSections(sections)
			self.dataSource?.apply(snapshot, animatingDifferences: true)
		}
	}

	func section(index: IndexPath) -> Section? {
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
