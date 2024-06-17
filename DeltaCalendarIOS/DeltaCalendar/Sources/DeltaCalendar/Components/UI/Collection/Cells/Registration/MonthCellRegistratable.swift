import UIKit

internal protocol MonthCellRegistratable {
	func daySelected(at index: Int)
}

extension MonthCellRegistratable where Self: AnyObject  {

	typealias MonthCellRegistration = UICollectionView
		.CellRegistration<MonthCollectionViewCell, MonthItem>

	func createMonthCellRegistration() -> MonthCellRegistration {
		MonthCellRegistration { [weak self] (cell, _, item) in
			cell.configure(with: item.days)

			cell.daySelectedHandler = { index in
				self?.daySelected(at: index)
			}
		}
	}
}
