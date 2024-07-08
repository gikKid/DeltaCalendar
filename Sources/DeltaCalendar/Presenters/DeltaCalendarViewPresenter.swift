import Foundation
import Combine

internal final class DeltaCalendarViewPresenter: DeltaCalendarViewPresentable {

	typealias DataSource = DeltaCalendarView.DeltaCalendarDataSource

	@Published private var currentMonthIndex: Int = 0
	private(set) var yearsItem: YearsItem?
    private(set) var mockConfigItem: MockConfigItem?
	weak var viewModel: DeltaCalendarViewModelProtocol?
	weak var dataSource: DataSource?
    public weak var delegate: DeltaCalendarViewPresenterDelegate?

	private var currentYearIndex: Int = 0 {
		didSet {
			self.unselectDay()
		}
	}

	@Published private(set) var selectedData: SelectedModel? {
		didSet {
            self.reloadItems(with: [self.dayTimeItem.id], animated: true)
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
        self.viewModel?.delegate = self
	}

	func setupDS() {
        guard let selectedYearIndex = self.viewModel?.data.firstIndex(where: { $0.isSelected })
        else { fatalError(CalendarError.selectingYear.description) }

		guard var snapshot = self.dataSource?.snapshot() else { return }

        self.currentYearIndex = selectedYearIndex

        let sections: [Section] = [.year, .month, .time]

        snapshot.appendSections(sections)

        self.dataSource?.apply(snapshot, animatingDifferences: false)

        self.configureYearsSection()
        self.reconfigureMonths()
		self.configureDayTimeSection()

        self.delegate?.calendarDSConfigured()
	}

    func showConfiguring() {
        guard var snapshot = self.dataSource?.snapshot() else { return }

        snapshot.appendSections([.loading])

        self.dataSource?.apply(snapshot, animatingDifferences: false)

        self.configureLoadingSection()
    }

	// MARK: - Updating state methods

    func yearSelected(updateData: UpdateSelectingModel, month: Int) {
		guard updateData.index != self.currentYearIndex else { return }

		self.viewModel?.toggleYearSelecting(updateData)

		self.currentYearIndex = updateData.index
		self.currentMonthIndex = month
		self.selectedData = nil

		self.reconfigureMonths()
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
        let now = Resources.today
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

// MARK: - ViewModelDelegate

extension DeltaCalendarViewPresenter: DeltaCalendarViewModelDelegate {
    func calendarConfigured() {
        guard var snapshot = self.dataSource?.snapshot() else { return }

        snapshot.deleteSections([.loading])

        self.dataSource?.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.mockConfigItem = nil
            self?.setupDS()
        }
    }
}

private extension DeltaCalendarViewPresenter {

	func setSelectedDate(by dayIndex: Int) {
		self.selectedData = .init(yearIndex: self.currentYearIndex, monthIndex: self.currentMonthIndex,
								  dayIndex: dayIndex)
	}

	// MARK: - Configuring sections

    func configureLoadingSection() {
        guard let month = self.viewModel?.data.first?.months.first else { return }

        self.mockConfigItem = .init(data: month.days)

        guard let id = self.mockConfigItem?.id else { return }

        var section = SectionSnapshot()
        section.append([id])

        self.dataSource?.apply(section, to: .loading, animatingDifferences: false)
    }

    func configureYearsSection() {
		guard let data = self.viewModel?.data else { return }

		self.yearsItem = .init(data: data)

		guard let id = self.yearsItem?.id else { return }

		var sectionSnapshot = SectionSnapshot()
		sectionSnapshot.append([id])

		self.dataSource?.apply(sectionSnapshot, to: .year, animatingDifferences: true)
	}

	func configureNextYear() {
		guard let data = self.viewModel?.data, self.currentYearIndex < data.count - 1
		else { return }

        let nextYear = data[self.currentYearIndex + 1]

        guard !nextYear.isMock else { return }

        let model = UpdateSelectingModel(prevIndex: self.currentYearIndex, index: self.currentYearIndex + 1)
        self.yearSelected(updateData: model, month: 0)
        self.configureYearsSection()
	}

	func configurePrevYear() {
        guard let data = self.viewModel?.data, self.currentYearIndex != 0 else { return }

        let prevYear = data[self.currentYearIndex - 1]

        guard !prevYear.isMock else { return }

        let model = UpdateSelectingModel(prevIndex: self.currentYearIndex, index: self.currentYearIndex - 1)
        self.yearSelected(updateData: model, month: Resources.monthCount - 1)
        self.configureYearsSection()
	}

	func reconfigureMonths() {
		guard let data = self.viewModel?.data else { return }

		let ids = data[self.currentYearIndex].months.map { $0.id }
		var sectionSnapshot = SectionSnapshot()
		sectionSnapshot.append(ids)

		self.dataSource?.apply(sectionSnapshot, to: .month, animatingDifferences: true)
	}

    func configureDayTimeSection() {
		var sectionSnapshot = SectionSnapshot()
		sectionSnapshot.append([self.dayTimeItem.id])

		self.dataSource?.apply(sectionSnapshot, to: .time, animatingDifferences: true)
	}

	// MARK: Update sections logic

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
        case .year, .time, .loading: break
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
