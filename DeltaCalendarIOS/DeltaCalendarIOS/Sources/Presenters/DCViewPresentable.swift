import Foundation
import Combine

protocol DeltaCalendarViewPresentable: AnyObject {

	typealias DataSource = DeltaCalendarView.DeltaCalendarDataSource

	var dataSource: DataSource? { get set }
	var viewModel: DeltaCalendarViewModelProtocol? { get set }
	var monthIndexPublisher: AnyPublisher<IndexPath, Never> { get }
	var selectedDatePublisher: AnyPublisher<Date?, Never> { get }
	var currentYearIndex: Int { get }
	var currentMonthIndex: IndexPath { get }
	var selectedData: DCSelectedModel? { get }

	func setupDS(with completion: @escaping () -> Void)
	func makeNextMonth()
	func makePrevMonth()
	func itemScrolled(currentItem: IndexPath)
	func currentMonth() -> IndexPath?
	func updateDaySelecting(at dayIndex: Int)
	func month(at index: Int) -> DCalendarMonthItem?
	func monthTitle() -> String
}
