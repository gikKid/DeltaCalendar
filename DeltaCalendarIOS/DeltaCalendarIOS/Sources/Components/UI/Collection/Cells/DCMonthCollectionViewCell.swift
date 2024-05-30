import UIKit

final class DCMonthCollectionViewCell: UICollectionViewCell {

	private lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView()
		collectionView.backgroundColor = .clear
		collectionView.bounces = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		return collectionView
	}()

	private var days: [DeltaCalendarDay] = []

	func configure(with data: [DeltaCalendarDay]) {
		self.days = data
	}
}
