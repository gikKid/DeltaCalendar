import Foundation

internal extension Date {
	func year(using calendar: Calendar = .current) -> Int {
		calendar.component(.year, from: self)
	}

	func month(using calendar: Calendar = .current) -> Int {
		calendar.component(.month, from: self)
	}

	func day(using calendar: Calendar = .current) -> Int {
		calendar.component(.day, from: self)
	}

	func hours(using calendar: Calendar = .current) -> Int {
		calendar.component(.hour, from: self)
	}

	func minutes(using calendar: Calendar = .current) -> Int {
		calendar.component(.minute, from: self)
	}
}
