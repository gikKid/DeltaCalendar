import UIKit

internal protocol ValueLayout {}

extension ValueLayout {

    func valueLayout(dataCount: Int) -> NSCollectionLayoutSection {
        let itemHeight: CGFloat = HeightResources.text

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )

        let items = (0..<dataCount).map { _ in NSCollectionLayoutItem(layoutSize: itemSize) }

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.33),
            heightDimension: .estimated(itemHeight)
        )

        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: items)
        group.interItemSpacing = .fixed(SpaceResources.moreMid)

        let section = NSCollectionLayoutSection(group: group)

        section.visibleItemsInvalidationHandler = { (items, offset, environment) in
            items.forEach { item in
                let distanceFromCenter = abs((item.frame.midX - offset.x) - environment.container.contentSize.width / 2.0)
                let minScale: CGFloat = Resources.minValScale
                let maxScale: CGFloat = Resources.maxValScale
                let scale = max(maxScale - (distanceFromCenter / environment.container.contentSize.width), minScale)

                item.transform = CGAffineTransform(scaleX: scale, y: scale)
            }
        }

        return section
    }
}
