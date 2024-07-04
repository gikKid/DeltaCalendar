import Foundation

// MARK: - StartModel

internal struct StartModel {
	let pickingYearData: PickingYearModel
	let showTimeData: ShowTimeModel
    let colors: Colors
}

// MARK: - PickingYearModel

public struct PickingYearModel {
	let from: Int
	let to: Int

	public init(from: Int, to: Int) {

        guard from <= to else { fatalError(CalendarError.fromToYears.description) }

		self.from = from
		self.to = to
	}
}

// MARK: - ShowTimeModel

public struct ShowTimeModel {
	let data: [DayTimeStartModel]
	let offset: Int

	public init(data: [DayTimeStartModel], offset: Int) {

        guard offset >= 1 else { fatalError(CalendarError.timeOffset.description) }

		self.data = data
		self.offset = offset
	}
}

// MARK: - DayTimeStartModel

public struct DayTimeStartModel {
	let weekday: Int
	let startDate: Date
	let endDate: Date

	public init(weekday: Int, startDate: String, endDate: String) {

		guard (1...7).contains(weekday) else {
            fatalError(CalendarError.weekday(weekday).description)
		}

		let format = Resources.timeFormat
		let timeFormatter = DateFormatter.build(format: format)

		guard let start = timeFormatter.date(from: startDate),
			  let end = timeFormatter.date(from: endDate)
        else { fatalError(CalendarError.timeFormat(format).description) }

		guard start.hours() <= end.hours(), start.minutes() <= end.minutes() else {
            fatalError(CalendarError.startEndTime.description)
		}

		self.startDate = start
		self.endDate = end
		self.weekday = weekday
	}
}