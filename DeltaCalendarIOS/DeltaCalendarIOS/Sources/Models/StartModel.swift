import Foundation

internal struct StartModel {
	let theme: Theme
	var weekendsOff: Bool
	let pastDaysOff: Bool
	var pickingYearData: PickingYearModel?
	let showTimeData: ShowTimeModel?
}

struct PickingYearModel {
	let from: Int
	let to: Int
}

internal struct ShowTimeModel {
	let startDate: Date
	let endDate: Date
	let offset: Int
}

internal enum Theme {
	case light, dark
}
