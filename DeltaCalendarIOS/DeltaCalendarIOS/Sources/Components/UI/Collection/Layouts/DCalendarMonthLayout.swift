import UIKit

protocol DCalendarMonthLayout {
	func monthTitle(at: IndexPath) -> String
	func nextMonthTapped()
	func prevMonthTapped()
}

extension DCalendarMonthLayout where Self: AnyObject {

	typealias DCMonthCellRegistration = UICollectionView
		.CellRegistration<DCMonthCollectionViewCell, DCalendarMonthItem>

	typealias DCMonthHeaderRegistration = UICollectionView
		.SupplementaryRegistration<DCMonthCollectionReusableView>

	// MARK: - Layout

	func DCMonthLayout() -> NSCollectionLayoutSection {

		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											  heightDimension: .fractionalHeight(1))

		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])

		let headerHeight = DCHeightResources.text
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

	func createDCMonthCellRegistration(_ theme: DeltaCalendarTheme) -> DCMonthCellRegistration {
		DCMonthCellRegistration { (cell, _, item) in
			cell.configure(with: item.days, isWeekendsDisabled: item.isWeekendsDisabled, theme: theme)
		}
	}

	func createMonthHeaderRegistration(_ theme: DeltaCalendarTheme) -> DCMonthHeaderRegistration {
		DCMonthHeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) {
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
