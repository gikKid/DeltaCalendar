import UIKit

protocol DCalendarMonthLayout {}

extension DCalendarMonthLayout {

	typealias DCMonthCellRegistration = UICollectionView
		.CellRegistration<DCMonthCollectionViewCell, DCalendarMonthItem>

	func DCMonthLayout(parentFrame: CGRect) -> NSCollectionLayoutSection {

		let itemHeight = parentFrame.height / 3
		let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
											  heightDimension: .estimated(itemHeight))

		let item = NSCollectionLayoutItem(layoutSize: itemSize)

		let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = .groupPaging

		let sectionOffset = DCSpaceResources.moreMid

		section.contentInsets = .init(top: 0.0, leading: sectionOffset,
									  bottom: sectionOffset, trailing: sectionOffset)

		return section
	}

	func createDCMonthCellRegistration() -> DCMonthCellRegistration {
		DCMonthCellRegistration { (cell, _, item) in
			cell.configure(with: item.days)
		}
	}
}
