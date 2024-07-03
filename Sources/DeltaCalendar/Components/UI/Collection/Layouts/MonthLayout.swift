import UIKit

internal protocol MonthLayout {}

extension MonthLayout {

    func monthLayout(parentFrame: CGRect) -> NSCollectionLayoutSection {

        let itemHeight: CGFloat = parentFrame.height / 1.75

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
}
