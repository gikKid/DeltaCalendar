import Foundation

struct DCalendarMonthItem: Identifiable {
	let title: String
	let days: [DeltaCalendarDay]
	let isWeekendsDisabled: Bool
	let id: String = UUID().uuidString
}
