import Foundation

struct DCalendarMonthItem: Identifiable {
	let title: String
	let days: [DeltaCalendarDay]
	let id: String = UUID().uuidString
}
