import UIKit

internal protocol DaysLayout {}

extension DaysLayout {

	func daysLayout(parentFrame: CGRect) -> NSCollectionLayoutSection {

		let weekdaysCount = Resources.weekdays.count
		let itemHeight = HeightResources.day
		let itemWidth = parentFrame.width / CGFloat(weekdaysCount)
		let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth),
											  heightDimension: .absolute(itemHeight))

		let items = Range(1...weekdaysCount).map { _ in NSCollectionLayoutItem(layoutSize: itemSize) }

		let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											   heightDimension: .estimated(itemHeight))

		let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items)

		let section = NSCollectionLayoutSection(group: group)
		section.interGroupSpacing = SpaceResources.small

		return section
	}
}
