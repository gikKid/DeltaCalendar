import Foundation

struct DCalendarMonthItem: Identifiable {
	let title: String
	var days: [DCalendarDayItem]
	let id: String = UUID().uuidString
}
