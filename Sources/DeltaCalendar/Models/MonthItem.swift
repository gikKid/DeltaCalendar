import Foundation

internal struct MonthItem: Identifiable {
	let title: String
	var days: [DayItem]
	let id: ItemID = UUID().uuidString
}
