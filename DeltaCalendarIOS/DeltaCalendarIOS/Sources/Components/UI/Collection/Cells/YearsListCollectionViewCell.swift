import UIKit

internal final class YearsListCollectionViewCell: UICollectionViewCell, ValueLayout {

	typealias YearsDataSource = UICollectionViewDiffableDataSource<BaseSection, ItemID>
	typealias value = Int

	private lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
		collectionView.backgroundColor = .clear
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.bounces = false
		collectionView.delegate = self
		collectionView.collectionViewLayout = self.createCompositionLayout()
		return collectionView
	}()
	private lazy var dataSource: YearsDataSource = {
		self.createDataSource()
	}()
	private var data: [YearItem] = [] {
		didSet {
			let ids = self.data.map { $0.id }
			self.configureCollection(with: ids)
		}
	}

	public var selectHandler: ((Int) -> Void)?

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with data: [YearItem]) {
		guard self.data.isEmpty else { return }
		self.data = data
	}
}

// MARK: - CollectionViewDelegate

extension YearsListCollectionViewCell: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
	}
}

private extension YearsListCollectionViewCell {
	func setupView() {
		self.contentView.addSubview(self.collectionView)

		self.collectionView.snp.makeConstraints { $0.edges.equalTo(self.contentView) }
	}

	func configureCollection(with ids: [ItemID]) {
		guard !ids.isEmpty else { return }

		var snapshot = self.dataSource.snapshot()
		snapshot.appendSections([.main])

		self.dataSource.apply(snapshot, animatingDifferences: false)

		var section = SectionSnapshot()
		section.append(ids)

		self.dataSource.apply(section, to: .main, animatingDifferences: false)
	}

	// MARK: - DataSource

	func createDataSource() -> YearsDataSource {

		let valueRegistratrion = self.createValueCellRegistration()

		return YearsDataSource(collectionView: self.collectionView) {
			[weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in
			
			guard let year = self?.data[indexPath.row] else { return nil }

			let item = ValueItem(value: year.value, isSelected: false, id: year.id)
			return collectionView.dequeueConfiguredReusableCell(using: valueRegistratrion, for: indexPath, item: item)
		}
	}

	// MARK: - Layout

	func createCompositionLayout() -> UICollectionViewLayout {
		
		let sectionProvider = { [weak self] (sectionIndex: Int, environment: NSCollectionLayoutEnvironment)
			-> NSCollectionLayoutSection? in
			let frame = self?.contentView.frame ?? .zero
			let dataCount = self?.data.count ?? 0

			return self?.valueLayout(parentFrame: frame, dataCount: dataCount)
		}

		return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
	}
}
