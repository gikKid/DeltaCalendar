import Foundation
import Combine

internal final class DeltaCalendarViewPresenter: DeltaCalendarViewPresentable {

	typealias DataSource = DeltaCalendarView.DeltaCalendarDataSource

	@Published private var currentMonthIndex: Int = 0
	private(set) var yearsItem: YearsItem?
	weak var viewModel: DeltaCalendarViewModelProtocol?
	weak var dataSource: DataSource?

	private var currentYearIndex: Int {
		didSet {
			self.unselectDay()
		}
	}

	@Published private(set) var selectedData: SelectedModel? {
		didSet {
			self.updateDayTimeSection()
		}
	}

	private var dayTimeItem: DayTimeItem = {
		DayTimeItem(data: [], id: UUID().uuidString)
	}()

	public var monthIndexPublisher: AnyPublisher<Int, Never> {
		self.$currentMonthIndex.eraseToAnyPublisher()
	}
	public var selectedDatePublisher: AnyPublisher<Date?, Never> {
		self.$selectedData.map {
			guard let selectedData = $0, let data = self.viewModel?.data
			else { return nil }

			return data[selectedData.yearIndex].months[selectedData.monthIndex]
				.days[selectedData.dayIndex].data.date
		}.eraseToAnyPublisher()
	}

	// MARK: - Setting methods

	init(_ dataSource: DataSource, _ viewModel: DeltaCalendarViewModelProtocol) {
		self.dataSource = dataSource
		self.viewModel = viewModel

		guard let selectedYearIndex = viewModel.data.firstIndex(where: { $0.isSelected })
		else { fatalError("[ERROR]: Year was not selected.") }

		self.currentYearIndex = selectedYearIndex
	}

	func setupDS(with startData: StartModel) {
		guard var snapshot = self.dataSource?.snapshot() else { return }

        let sections: [Section] = [.year, .month, .time]

		snapshot.appendSections(sections)

		self.dataSource?.apply(snapshot, animatingDifferences: false)

        self.configureYearsSection(animated: false)
		self.reconfigureMonths(animated: false)
		self.configureDayTimeSection()
	}

	// MARK: - Updating state methods

    func yearSelected(updateData: UpdateSelectingModel, month: Int) {
		guard updateData.index != self.currentYearIndex else { return }

		self.viewModel?.toggleYearSelecting(updateData)

		self.currentYearIndex = updateData.index
		self.currentMonthIndex = month
		self.selectedData = nil

		self.reconfigureMonths(animated: true)
	}

	func timeSelected(_ data: UpdateSelectingModel) -> Date? {
		guard let selectedData else { return nil }
		return self.viewModel?.date(selectedData: selectedData, timeIndex: data.index)
	}

	func updateDaySelecting(at dayIndex: Int) {
		self.unselectDay()

		let selectModel = SelectedModel(yearIndex: self.currentYearIndex, monthIndex: self.currentMonthIndex,
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

        let months = data[self.currentYearIndex].months

        guard !months.isEmpty else { return nil }

		return months[index]
	}

	func dayTimeData() -> DayTimeItem {
		if let selectedData {
			let timeData = self.viewModel?.data[selectedData.yearIndex]
				.months[selectedData.monthIndex].days[selectedData.dayIndex].data.timeData ?? []

			self.dayTimeItem.data = timeData
		} else {
			self.dayTimeItem.data = []
		}

		return self.dayTimeItem
	}
}

private extension DeltaCalendarViewPresenter {

	func setSelectedDate(by dayIndex: Int) {
		self.selectedData = .init(yearIndex: self.currentYearIndex, monthIndex: self.currentMonthIndex,
								  dayIndex: dayIndex)
	}

	// MARK: - Configuring sections

    func configureYearsSection(animated: Bool) {
		guard let data = self.viewModel?.data else { return }

		self.yearsItem = .init(data: data)

		guard let id = self.yearsItem?.id else { return }

		var sectionSnapshot = SectionSnapshot()
		sectionSnapshot.append([id])

		self.dataSource?.apply(sectionSnapshot, to: .year, animatingDifferences: animated)
	}

	func configureNextYear() {
		guard let data = self.viewModel?.data, self.currentYearIndex < data.count - 1
		else { return }

        let nextYear = data[self.currentYearIndex + 1]

        guard !nextYear.isMock else { return }

        let model = UpdateSelectingModel(prevIndex: self.currentYearIndex, index: self.currentYearIndex + 1)
        self.yearSelected(updateData: model, month: 0)
        self.configureYearsSection(animated: true)
	}

	func configurePrevYear() {
        guard let data = self.viewModel?.data, self.currentYearIndex != 0 else { return }

        let prevYear = data[self.currentYearIndex - 1]

        guard !prevYear.isMock else { return }

        let model = UpdateSelectingModel(prevIndex: self.currentYearIndex, index: self.currentYearIndex - 1)
        self.yearSelected(updateData: model, month: Resources.monthCount - 1)
        self.configureYearsSection(animated: true)
	}

	func reconfigureMonths(animated: Bool) {
		guard let data = self.viewModel?.data else { return }

		let ids = data[self.currentYearIndex].months.map { $0.id }
		var sectionSnapshot = SectionSnapshot()
		sectionSnapshot.append(ids)

		self.dataSource?.apply(sectionSnapshot, to: .month, animatingDifferences: animated)
	}

	func configureDayTimeSection() {
		guard let snapshot = self.dataSource?.snapshot(), snapshot.sectionIdentifiers.contains(.time)
		else { return }

		var sectionSnapshot = SectionSnapshot()
		sectionSnapshot.append([self.dayTimeItem.id])

		self.dataSource?.apply(sectionSnapshot, to: .time, animatingDifferences: false)
	}

	// MARK: Update sections logic

	func updateDayTimeSection() {
		guard let snapshot = self.dataSource?.snapshot(),
			  snapshot.sectionIdentifiers.contains(.time) else { return }

		self.reloadItems(with: [self.dayTimeItem.id], animated: true)
	}

	func unselectDay() {
		guard let selectedData = self.selectedData else { return }

		let unselectModel = SelectedModel(yearIndex: selectedData.yearIndex,
										  monthIndex: selectedData.monthIndex,
										  dayIndex: selectedData.dayIndex)

		self.viewModel?.toggleSelecting(at: unselectModel)

		guard let data = self.viewModel?.data, selectedData.monthIndex != self.currentMonthIndex
		else { return }

		let prevMonthID = data[selectedData.yearIndex].months[selectedData.monthIndex].id
		self.reloadItems(with: [prevMonthID], animated: false)
	}

	func reloadItems(with ids: [ItemID], animated: Bool) {
		guard var snapshot = self.dataSource?.snapshot() else { return }

		if #available(iOS 15.0, *) {
			snapshot.reconfigureItems(ids)
		} else {
			snapshot.reloadItems(ids)
		}

		self.dataSource?.apply(snapshot, animatingDifferences: animated)
	}

	// MARK: - Scrolling logic

	func onItemScrolled(currentIndex: IndexPath, section: Section) {

		let index = currentIndex.row

		switch section {
		case .month: self.monthScrolled(to: index)
		case .year, .time: break
		}
	}

	func monthScrolled(to index: Int) {
		guard self.currentMonthIndex != index else { return }

		self.currentMonthIndex = index
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
