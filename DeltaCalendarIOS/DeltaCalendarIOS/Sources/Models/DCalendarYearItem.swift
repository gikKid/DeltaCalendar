import Foundation

struct DCalendarYearItem: Identifiable {
	let value: Int
	var months: [DCalendarMonthItem]
	let id: String = UUID().uuidString
}
