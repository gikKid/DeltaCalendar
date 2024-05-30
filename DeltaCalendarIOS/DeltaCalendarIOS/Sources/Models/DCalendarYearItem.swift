import Foundation

struct DCalendarYearItem: Identifiable {
	let title: String
	let months: [DCalendarMonthItem]
	let id: String = UUID().uuidString
}
