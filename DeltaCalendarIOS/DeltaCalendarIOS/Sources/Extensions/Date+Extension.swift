import Foundation

extension Date {
	func year(using calendar: Calendar = .current) -> Int {
		calendar.component(.year, from: self)
	}
}
