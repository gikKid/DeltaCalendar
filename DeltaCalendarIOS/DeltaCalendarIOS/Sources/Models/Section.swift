import UIKit

internal typealias ItemID = String
internal typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<ItemID>

internal enum Section {
//	case year, month, time
	case year, month

	init?(section: Int, isShowYear: Bool, isShowTime: Bool) {

		let yearSection: Int = isShowYear ? 0 : -1
		let monthSection: Int = isShowYear ? 1 : 0
//		let timeSection: Int = isShowTime ? (isShowYear ? 2 : 1) : -1

		switch section {
		case yearSection: 	self = .year
		case monthSection: 	self = .month
//		case timeSection: 	self = .time
		default: 			return nil
		}
	}
}

internal enum BaseSection: Int {
	case main
}
