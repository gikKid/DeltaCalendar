import UIKit

internal protocol MonthCellRegistratable {
	func daySelected(at index: Int)
}

extension MonthCellRegistratable where Self: AnyObject  {

	typealias MonthCellRegistration = UICollectionView
		.CellRegistration<MonthCollectionViewCell, MonthItem>

    func createMonthCellRegistration(colors: Colors) -> MonthCellRegistration {
		MonthCellRegistration { [weak self] (cell, _, item) in

            cell.daySelectedHandler = { index in
                self?.daySelected(at: index)
            }

            cell.configure(with: item.days, colors: colors)
		}
	}
}
