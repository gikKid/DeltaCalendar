import UIKit

internal protocol DayCellRegistratable {}

extension DayCellRegistratable {

	typealias DayCellRegistration = UICollectionView
		.CellRegistration<DayCollectionViewCell, DayItem>

	func createDayCellRegistration() -> DayCellRegistration {
		DayCellRegistration { (cell, _, item) in
			cell.configure(with: item)
		}
	}
}
