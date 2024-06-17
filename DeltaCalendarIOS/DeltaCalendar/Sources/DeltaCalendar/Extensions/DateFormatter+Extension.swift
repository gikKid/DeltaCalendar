import Foundation

internal extension DateFormatter {
	static func build(format: String, calendar: Calendar = .current,
					  locale: Locale = .current,
					  timeZone: TimeZone? = .init(secondsFromGMT: 0)) -> DateFormatter {

		let formatter = DateFormatter()
		formatter.dateFormat = format
		formatter.calendar = calendar
		formatter.timeZone = timeZone
		formatter.locale = locale

		return formatter
	}
}
