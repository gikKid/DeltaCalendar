import UIKit

typealias DeltaCalendarItemID = String
typealias DCSectionSnapshot = NSDiffableDataSourceSectionSnapshot<DeltaCalendarItemID>

enum DCalendarSection {
//	case year, month, days, time
	case days

//	init?(section: Int, isShowYear: Bool, isShowTime: Bool) {
//
//		let yearSection: Int = isShowYear ? 0 : -1
//		let monthSection: Int = isShowYear ? 1 : 0
//		let daysSection: Int = isShowYear ? 2 : 1
//		let timeSection: Int = isShowTime ? (isShowYear ? 3 : 2) : -1
//
//		switch section {
//		case yearSection: 	self = .year
//		case monthSection: 	self = .month
//		case daysSection: 	self = .days
//		case timeSection: 	self = .time
//		default: 			return nil
//		}
//	}
}

enum DCBaseSection {
	case main
}
