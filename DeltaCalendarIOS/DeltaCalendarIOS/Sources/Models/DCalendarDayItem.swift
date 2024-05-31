import Foundation

struct DCalendarDayItem: Identifiable {
	let data: DeltaCalendarDay
	let colors: DCalendarDayColors
	let isDisabled: Bool
	let id: String = UUID().uuidString
	var isSelected: Bool = false
}

struct DeltaCalendarDay {
	let title: String
	let description: String
	let weekday: Int
}
