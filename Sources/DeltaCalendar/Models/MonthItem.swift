import Foundation

internal struct MonthItem: Identifiable {
	let title: String
    let date: Date
	var days: [DayItem]
	let id: ItemID = UUID().uuidString
}
