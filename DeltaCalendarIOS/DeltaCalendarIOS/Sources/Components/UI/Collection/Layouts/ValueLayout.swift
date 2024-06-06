import UIKit

internal protocol ValueLayout {
	associatedtype value: CustomStringConvertible
}

extension ValueLayout where Self: AnyObject {
	
	typealias ValueCellRegistration = UICollectionView.CellRegistration<ValueCollectionViewCell, ValueItem>

	func valueLayout(parentFrame: CGRect, dataCount: Int) -> NSCollectionLayoutSection {

		let itemWidth = parentFrame.width / 3.5
		let itemHeight: CGFloat = HeightResources.text / 2
		let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(itemWidth),
											  heightDimension: .estimated(itemHeight))

		let items = (0..<dataCount).map { _ in NSCollectionLayoutItem(layoutSize: itemSize) }

		let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: items)
		group.interItemSpacing = .fixed(SpaceResources.moreMid)

		let section = NSCollectionLayoutSection(group: group)
		section.orthogonalScrollingBehavior = .continuous

		return section
	}

	func createValueCellRegistration() -> ValueCellRegistration {
		ValueCellRegistration { (cell, _, item) in
			cell.configure(text: item.value, isSelected: item.isSelected)
		}
	}
}

internal struct ValueItem: Identifiable {
	let value: CustomStringConvertible
	var isSelected: Bool
	let id: ItemID
}
