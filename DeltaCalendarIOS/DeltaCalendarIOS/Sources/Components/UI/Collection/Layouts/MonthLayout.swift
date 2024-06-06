import UIKit

internal protocol MonthLayout {
	func monthTitle(at: IndexPath) -> String
	func nextMonthTapped()
	func prevMonthTapped()
	func daySelected(at index: Int)
}

extension MonthLayout where Self: AnyObject {

	typealias MonthCellRegistration = UICollectionView
		.CellRegistration<MonthCollectionViewCell, MonthItem>

	typealias MonthHeaderRegistration = UICollectionView
		.SupplementaryRegistration<MonthCollectionReusableView>

	// MARK: - Layout

	func monthLayout(parentFrame: CGRect) -> NSCollectionLayoutSection {

		let itemHeight: CGFloat = parentFrame.height / 1.5
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											  heightDimension: .estimated(itemHeight))

		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])

		let headerHeight = HeightResources.text
		let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
												heightDimension: .estimated(headerHeight))

		let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
																	 elementKind: UICollectionView.elementKindSectionHeader,
																	 alignment: .top)

		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = .groupPaging
		section.boundarySupplementaryItems = [headerItem]

		return section
	}

	// MARK: - Registration

	func createMonthCellRegistration() -> MonthCellRegistration {
		MonthCellRegistration { [weak self] (cell, _, item) in
			cell.configure(with: item.days)

			cell.daySelectedHandler = { index in
				self?.daySelected(at: index)
			}
		}
	}

	func createMonthHeaderRegistration(_ theme: Theme) -> MonthHeaderRegistration {
		MonthHeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) {
			[weak self] (view, _, indexPath) in
			let title = self?.monthTitle(at: indexPath) ?? "-"

			view.configure(monthTitle: title, theme: theme)

			view.eventHandler = { event in
				switch event {
				case .nextMonth: self?.nextMonthTapped()
				case .prevMonth: self?.prevMonthTapped()
				}
			}
		}
	}
}
