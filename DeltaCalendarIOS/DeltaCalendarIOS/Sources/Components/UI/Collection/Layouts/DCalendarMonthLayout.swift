import UIKit

protocol DCalendarDaysLayout {}

extension DCalendarDaysLayout {

	typealias DCDayCellRegistration = UICollectionView
		.CellRegistration<DCDayCollectionViewCell, DCalendarDayItem>

	func DCDaysLayout(parentFrame: CGRect) -> NSCollectionLayoutSection {

		let itemHeight = DCHeightResources.day
		let itemWidth = parentFrame.width / CGFloat(DCResources.daysInWeek)
		let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(itemWidth),
											  heightDimension: .estimated(itemHeight))

		let items = Range(1...DCResources.daysInWeek).map { _ in NSCollectionLayoutItem(layoutSize: itemSize) }

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											   heightDimension: .estimated(itemHeight))

		let space = DCSpaceResources.mid

		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items)
		group.interItemSpacing = .fixed(space)

		let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = space

		return section
	}

	func createDCDayCellRegistration() -> DCDayCellRegistration {
		DCDayCellRegistration { (cell, _, item) in
			cell.configure(with: item)
		}
	}
}
