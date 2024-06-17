import Foundation

internal struct DayTime: Identifiable {
	var isSelected: Bool
	let title: String
	let isMock: Bool
	let id: ItemID = UUID().uuidString

	init(value: Date, isSelected: Bool, isMock: Bool) {
		self.isSelected = isSelected
		self.isMock = isMock

		let timeFormatter = DateFormatter.build(format: Resources.timeFormat)
		self.title = isMock ? "" : timeFormatter.string(from: value)
	}
}

internal struct DayTimeItem: Identifiable {
	var data: [DayTime]
	let id: ItemID
}
