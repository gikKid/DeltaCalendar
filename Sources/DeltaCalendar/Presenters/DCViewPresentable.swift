import Foundation
import Combine

internal protocol DeltaCalendarViewPresenterDelegate: AnyObject {
    func calendarDSConfigured()
}

internal protocol DeltaCalendarViewPresentable: AnyObject {

    var delegate: DeltaCalendarViewPresenterDelegate? { get set }
    var viewModel: DeltaCalendarViewModelProtocol? { get set }
    var monthIndexPublisher: AnyPublisher<Int, Never> { get }
    var selectedDatePublisher: AnyPublisher<Date?, Never> { get }
    var selectedData: SelectedModel? { get }
    var yearsItem: YearsItem? { get }
    var mockConfigItem: MockConfigItem? { get }

    func showConfiguring()
    func setupDS()
    func makeNextMonth()
    func makePrevMonth()
    func itemScrolled(currentItem: IndexPath)
    func currentMonth() -> IndexPath?
    func updateDaySelecting(at dayIndex: Int)
    func month(at index: Int) -> MonthItem?
    func yearSelected(updateData: UpdateSelectingModel, month: Int)
    func dayTimeData() -> DayTimeItem
    func timeSelected(_ data: UpdateSelectingModel) -> Date?
}
