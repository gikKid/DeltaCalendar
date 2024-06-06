import Foundation

internal struct MonthItem: Identifiable {
	let title: String
	var days: [DayItem]
	let id: String = UUID().uuidString
}
