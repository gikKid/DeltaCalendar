import Foundation

internal extension DateFormatter {
	static func build(format: String) -> DateFormatter {

		let formatter = DateFormatter()
		formatter.dateFormat = format
        formatter.calendar = .init(identifier: .gregorian)
		formatter.timeZone = .init(secondsFromGMT: 0)
        formatter.locale = .init(identifier: Resources.locale)

		return formatter
	}
}
