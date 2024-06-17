import UIKit

internal final class MonthCollectionViewCell: UICollectionViewCell {

	typealias DCMonthDataSource = UICollectionViewDiffableDataSource<BaseSection, ItemID>

	private lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
		collectionView.backgroundColor = .clear
		collectionView.bounces = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.delegate = self
		collectionView.collectionViewLayout = self.createCompositionLayout()
		return collectionView
	}()
	private lazy var dataSource: DCMonthDataSource = {
		self.createDataSource()
	}()
	private var items: [DayItem] = [] {
		didSet {
			let ids = self.items.map { $0.id }
			self.setupCollection(by: ids)
		}
	}
	public var daySelectedHandler: ((Int) -> Void)?

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with data: [DayItem]) {
		self.items = data
	}
}

// MARK: - CollectionViewDelegate

extension MonthCollectionViewCell: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		var ids = [ItemID]()

		if let prevSelectedIndex = self.items.firstIndex(where: { $0.isSelected }),
		   prevSelectedIndex != indexPath.row {
			self.items[prevSelectedIndex].isSelected.toggle()

			let id = self.items[prevSelectedIndex].id
			ids.append(id)
		}

		self.items[indexPath.row].isSelected.toggle()

		self.daySelectedHandler?(indexPath.row)

		let id = self.items[indexPath.row].id
		ids.append(id)

		var snapshot = self.dataSource.snapshot()
		snapshot.reloadItems(ids)

		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}

private extension MonthCollectionViewCell {

	// MARK: - Configuring

	func setupView() {
		self.contentView.addSubview(self.collectionView)

		self.collectionView.snp.makeConstraints {
			$0.edges.equalTo(self.contentView)
		}
	}

	func setupCollection(by ids: [ItemID]) {
		guard !ids.isEmpty else { return }

		var snapshot = self.dataSource.snapshot()

		if snapshot.itemIdentifiers.isEmpty {
			snapshot.appendSections([.main])
		}

		snapshot.deleteAllItems()

		self.dataSource.apply(snapshot, animatingDifferences: false)

		var sectionSnapshot = SectionSnapshot()
		sectionSnapshot.append(ids)

		self.dataSource.apply(sectionSnapshot, to: .main, animatingDifferences: false)
	}

	// MARK: - Layout

	func createCompositionLayout() -> UICollectionViewLayout {

		let sectionProvider = { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment)
			-> NSCollectionLayoutSection? in

			let frame = self?.contentView.frame ?? .zero

			return self?.daysLayout(parentFrame: frame)
		}

		return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
	}

	// MARK: - DataSource

	func createDataSource() -> DCMonthDataSource {

		let dayRegistration = self.createDayCellRegistration()

		return DCMonthDataSource(collectionView: self.collectionView) {
			[weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in

			let item = self?.items[indexPath.row]
			return collectionView.dequeueConfiguredReusableCell(using: dayRegistration, for: indexPath, item: item)
		}
	}
}

extension MonthCollectionViewCell: DaysLayout, DayCellRegistratable {}
