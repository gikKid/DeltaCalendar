import Foundation
import Combine

internal protocol DeltaCalendarViewPresentable: AnyObject {

	typealias DataSource = DeltaCalendarView.DeltaCalendarDataSource

	var dataSource: DataSource? { get set }
	var viewModel: DeltaCalendarViewModelProtocol? { get set }
	var monthIndexPublisher: AnyPublisher<Int, Never> { get }
	var selectedDatePublisher: AnyPublisher<Date?, Never> { get }
	var currentYearIndex: Int { get }
	var currentMonthIndex: Int { get }
	var selectedData: SelectedModel? { get }
	var yearsItem: YearsItem? { get }

	func setupDS(with startData: StartModel)
	func makeNextMonth()
	func makePrevMonth()
	func itemScrolled(currentItem: IndexPath)
	func currentMonth() -> IndexPath?
	func updateDaySelecting(at dayIndex: Int)
	func month(at index: Int) -> MonthItem?
	func monthTitle() -> String
	func section(at index: Int, startData: StartModel) -> Section?
}
