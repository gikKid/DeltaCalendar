import UIKit

extension UICollectionView {
	func currentIndexPath() -> IndexPath? {
		let visibleRect = CGRect(origin: self.contentOffset, size: self.bounds.size)
		let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

		return self.indexPathForItem(at: visiblePoint)
	}
}
