import Foundation

// MARK: - StartModel

internal struct StartModel {
	let theme: Theme
	var weekendsOff: Bool
	let pastDaysOff: Bool
	var pickingYearData: PickingYearModel?
	let showTimeData: ShowTimeModel?
}

// MARK: - PickingYearModel

struct PickingYearModel {
	let from: Int
	let to: Int

	init(from: Int, to: Int) {

		guard from <= to else { fatalError("[ERROR]: 'From' year must be equal or less than 'to' year.") }

		self.from = from
		self.to = to
	}
}

// MARK: - ShowTimeModel

struct ShowTimeModel {
	let data: [DayTimeModel]
	let offset: Int

	init(data: [DayTimeModel], offset: Int) {

		guard offset >= 1 else { fatalError("[ERROR]: Time offset must be equal or more than 1.") }

		self.data = data
		self.offset = offset
	}
}

// MARK: - DayTimeModel

struct DayTimeModel {
	let weekday: Int
	let startDate: Date
	let endDate: Date

	init(weekday: Int, startDate: String, endDate: String) {

		guard (1...7).contains(weekday) else {
			fatalError("[ERROR]: Weekday is not correct. It must be value between 1 and 7 (\(weekday)")
		}

		let timeFormat = Resources.timeFormat
		let dateFormatte = DateFormatter()
		dateFormatte.locale = .current
		dateFormatte.timeZone = .init(secondsFromGMT: 0)
		dateFormatte.dateFormat = timeFormat

		guard let start = dateFormatte.date(from: startDate),
			  let end = dateFormatte.date(from: endDate)
		else { fatalError("[ERROR]: Date format is '\(timeFormat)'") }

		guard start.hours() <= end.hours(), start.minutes() <= end.minutes() else {
			fatalError("[ERROR]: 'Start date' parameter must be less than 'end date' parameter at time in day")
		}

		self.startDate = start
		self.endDate = end
		self.weekday = weekday
	}
}

// MARK: - Theme

enum Theme {
	case light, dark
}
