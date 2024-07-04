import Foundation

internal struct YearItem: Identifiable {
	let value: Int
	var months: [MonthItem]
	var isSelected: Bool
	let isMock: Bool /// need adding extra first and last empty mock item for user can scroll to first and last year at range.
	let id: ItemID = UUID().uuidString

    static func mockData() -> [YearItem] {
        let day = Day(title: "", description: "", weekday: -1, date: nil, timeData: [])

        let days: [DayItem] = [
            .init(data: day, isDisabled: true, isSelected: false),
            .init(data: day, isDisabled: true, isSelected: false),
            .init(data: day, isDisabled: true, isSelected: false),
            .init(data: day, isDisabled: true, isSelected: false),
        ]

        let month = MonthItem(title: "", days: days)

        return [ .init(value: 2024, months: [month], isSelected: false, isMock: false) ]
    }
}

internal struct YearsItem: Identifiable {
	let data: [YearItem]
	let id: ItemID = UUID().uuidString
}
