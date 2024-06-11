import Foundation

internal struct DayItem: Identifiable {
	let data: Day
	let colors: DayColors
	var isDisabled: Bool
	let id: String = UUID().uuidString
	var isSelected: Bool
}

internal struct Day {
	let title: String
	let description: String
	let weekday: Int
	let date: Date?
	let time: [Date]
}
