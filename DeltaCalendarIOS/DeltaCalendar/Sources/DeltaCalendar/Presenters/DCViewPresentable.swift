import Foundation
import Combine

internal protocol DeltaCalendarViewPresentable: AnyObject {

	var viewModel: DeltaCalendarViewModelProtocol? { get set }
	var monthIndexPublisher: AnyPublisher<Int, Never> { get }
	var selectedDatePublisher: AnyPublisher<Date?, Never> { get }
	var selectedData: SelectedModel? { get }
	var yearsItem: YearsItem? { get }

	func setupDS(with startData: StartModel)
	func makeNextMonth()
	func makePrevMonth()
	func itemScrolled(currentItem: IndexPath)
	func currentMonth() -> IndexPath?
	func updateDaySelecting(at dayIndex: Int)
	func month(at index: Int) -> MonthItem?
	func section(at index: Int, startData: StartModel) -> Section?
	func yearSelected(_ data: UpdateSelectingModel)
	func dayTimeData() -> DayTimeItem
	func timeSelected(_ data: UpdateSelectingModel) -> Date?
}
