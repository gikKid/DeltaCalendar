import Foundation

internal struct YearItem: Identifiable {
	let value: Int
	var months: [MonthItem]
	var isSelected: Bool
	let id: String = UUID().uuidString
}

internal struct YearsItem: Identifiable {
	let data: [YearItem]
	let id: String = UUID().uuidString
}
