import Foundation

extension Date {
	func year(using calendar: Calendar = .current) -> Int {
		calendar.component(.year, from: self)
	}

	func month(using calendar: Calendar = .current) -> Int {
		calendar.component(.month, from: self)
	}

	func day(using calendar: Calendar = .current) -> Int {
		calendar.component(.day, from: self)
	}

	static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.year() == rhs.year() && lhs.month() == rhs.month() && lhs.day() == rhs.day()
	}
}
