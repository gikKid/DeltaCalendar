import UIKit

internal protocol YearsListCellRegistratable {
	func yearSelected(_ data: UpdateSelectingModel)
}

extension YearsListCellRegistratable where Self: AnyObject {

	typealias YearsListCellRegistration = UICollectionView
		.CellRegistration<YearsListCollectionViewCell, YearsItem>

	func createYearsCellRegistration() -> YearsListCellRegistration {
		YearsListCellRegistration { [weak self] (cell, _, item) in
			cell.configure(with: item.data)

			cell.selectHandler = { [weak self] updateData in
				self?.yearSelected(updateData)
			}
		}
	}
}
