import UIKit

internal protocol YearsListLayout {
	func yearSelected(year: Int)
}

extension YearsListLayout where Self: AnyObject {

	typealias YearsListCellRegistration = UICollectionView
		.CellRegistration<YearsListCollectionViewCell, YearsItem>

	func yearsLayout() -> NSCollectionLayoutSection {

		let itemHeight = TextSizeResources.moreBig
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

	func createYearsCellRegistration() -> YearsListCellRegistration {
		YearsListCellRegistration { [weak self] (cell, _, item) in
			cell.configure(with: item.data)

			cell.selectHandler = { [weak self] year in
				self?.yearSelected(year: year)
			}
		}
	}
}
