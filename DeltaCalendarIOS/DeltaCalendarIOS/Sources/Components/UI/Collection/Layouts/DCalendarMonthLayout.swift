import UIKit

protocol DCalendarMonthLayout {}

extension DCalendarMonthLayout {

	typealias DCMonthCellRegistration = UICollectionView
		.CellRegistration<DCMonthCollectionViewCell, DCalendarMonthItem>

	typealias DCWeekdaysHeaderRegistration = UICollectionView
		.SupplementaryRegistration<DCWeekDaysCollectionReusableView>

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

	func createDCMonthCellRegistration(_ theme: DCalendarTheme) -> DCMonthCellRegistration {
		DCMonthCellRegistration { (cell, _, item) in
			cell.configure(with: item.days, isWeekendsDisabled: item.isWeekendsDisabled, theme: theme)
		}
	}

	func createWeekdaysHeaderRegistration() -> DCWeekdaysHeaderRegistration {
		DCWeekdaysHeaderRegistration(elementKind: UICollectionView.elementKindSectionHeader) { (_, _, _) in }
	}
}
