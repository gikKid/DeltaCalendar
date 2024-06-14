import UIKit

internal protocol ValueListLayout {}

extension ValueListLayout {

	func valueListLayout() -> NSCollectionLayoutSection {

		let itemHeight = HeightResources.text
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											  heightDimension: .estimated(itemHeight))

		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])

		let section = NSCollectionLayoutSection(group: group)

		let yOffset = SpaceResources.moreMid
		let xOffset = SpaceResources.big
		section.contentInsets = .init(top: yOffset, leading: xOffset, 
									  bottom: yOffset * 2, trailing: xOffset)

		return section
	}
}
