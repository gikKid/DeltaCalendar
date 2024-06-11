import Foundation

internal struct YearItem: Identifiable {
	let value: Int
	var months: [MonthItem]
	var isSelected: Bool
	let isMock: Bool /// need adding extra first and last empty mock item for user can scroll to first and last year at range.
	let id: String = UUID().uuidString
}

internal struct YearsItem: Identifiable {
	let data: [YearItem]
	let id: String = UUID().uuidString
}
