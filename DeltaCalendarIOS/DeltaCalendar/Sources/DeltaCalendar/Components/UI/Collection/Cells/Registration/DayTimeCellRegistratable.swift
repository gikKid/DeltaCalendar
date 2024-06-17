import UIKit

internal protocol DayTimeCellRegistratable {
	func timeSelected(_ data: UpdateSelectingModel)
}

extension DayTimeCellRegistratable where Self: AnyObject {

	typealias DayTimeCellRegistration = UICollectionView
		.CellRegistration<DayTimeListCollectionViewCell, DayTimeItem>

	func createDayTimeRegistration() -> DayTimeCellRegistration {
		DayTimeCellRegistration { [weak self] (cell, _, item) in
			cell.configure(with: item.data)

			cell.selectHandler = { updateData in
				self?.timeSelected(updateData)
			}
		}
	}
}
