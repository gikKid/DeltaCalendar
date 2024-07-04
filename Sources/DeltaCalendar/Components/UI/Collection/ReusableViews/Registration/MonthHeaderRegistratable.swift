import UIKit

internal protocol MonthHeaderRegistratable {
	func monthTitle(at index: Int) -> String
	func nextMonthTapped()
	func prevMonthTapped()
}

extension MonthHeaderRegistratable where Self: AnyObject {

	typealias MonthHeaderRegistration = UICollectionView
		.SupplementaryRegistration<MonthCollectionReusableView>

    func createMonthHeaderRegistration(textColor: UIColor) -> MonthHeaderRegistration {
		MonthHeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) {
			[weak self] (view, _, indexPath) in

			let title = self?.monthTitle(at: indexPath.row) ?? "-"

			view.configure(monthTitle: title, textColor: textColor)

			view.eventHandler = { event in
				switch event {
				case .nextMonth: self?.nextMonthTapped()
				case .prevMonth: self?.prevMonthTapped()
				}
			}
		}
	}
}
