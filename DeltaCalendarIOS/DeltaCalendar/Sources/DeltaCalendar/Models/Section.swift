import UIKit

internal typealias ItemID = String
internal typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<ItemID>

internal enum Section {
	case year, month, time

	init?(index: Int) {
		switch index {
		case 0:  self = .year
		case 1:  self = .month
		case 2:  self = .time
		default: return nil
		}
	}
}

internal enum BaseSection: Int {
	case main
}
