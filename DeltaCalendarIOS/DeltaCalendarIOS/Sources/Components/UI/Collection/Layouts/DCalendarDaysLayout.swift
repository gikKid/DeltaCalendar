import UIKit

protocol DCalendarDaysLayout {}

extension DCalendarDaysLayout {

	typealias DCDayCellRegistration = UICollectionView
		.CellRegistration<DCDayCollectionViewCell, DCalendarDayItem>

	func DCDaysLayout(parentFrame: CGRect) -> NSCollectionLayoutSection {

		let weekdaysCount = DCResources.weekdays.count
		let itemHeight = DCHeightResources.day
		let itemWidth = parentFrame.width / CGFloat(weekdaysCount)
		let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth),
											  heightDimension: .absolute(itemHeight))

		let items = Range(1...weekdaysCount).map { _ in NSCollectionLayoutItem(layoutSize: itemSize) }

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											   heightDimension: .estimated(itemHeight))

		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items)

		let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = DCSpaceResources.mid

		return section
	}

	func createDCDayCellRegistration() -> DCDayCellRegistration {
		DCDayCellRegistration { (cell, _, item) in
			cell.configure(with: item)
		}
	}
}
