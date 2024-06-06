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
}
