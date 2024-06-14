import UIKit

internal final class YearsListCollectionViewCell: UICollectionViewCell {

	typealias YearsDataSource = UICollectionViewDiffableDataSource<BaseSection, ItemID>

	private lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
		collectionView.backgroundColor = .clear
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.bounces = false
		collectionView.delegate = self
		collectionView.decelerationRate = .fast
		collectionView.collectionViewLayout = self.createCompositionLayout()
		return collectionView
	}()
	private lazy var dataSource: YearsDataSource = {
		self.createDataSource()
	}()
	private var data: [YearItem] = []

	public var selectHandler: ((UpdateSelectingModel) -> Void)?

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

		self.configureCollection(with: data)
	}
}

// MARK: - UICollectionViewDelegate

extension YearsListCollectionViewCell: UICollectionViewDelegate {

	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, 
						forItemAt indexPath: IndexPath) {
		UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: Resources.feedbackVal)
	}

	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		guard !decelerate else { return }
		self.selectYear()
	}

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		self.selectYear()
	}
}

private extension YearsListCollectionViewCell {

	// MARK: - Setting logic

	func setupView() {
		self.contentView.addSubview(self.collectionView)

		self.collectionView.snp.makeConstraints { $0.edges.equalTo(self.contentView) }
	}

	func configureCollection(with data: [YearItem]) {
		guard !data.isEmpty, let selectedRow = self.data.firstIndex(where: { $0.isSelected })
		else { return }

		var snapshot = self.dataSource.snapshot()
		snapshot.appendSections([.main])

		self.dataSource.apply(snapshot, animatingDifferences: false)

		let ids = self.data.map { $0.id }
		let selectedIndexPath = IndexPath(row: selectedRow, section: BaseSection.main.rawValue)

		var section = SectionSnapshot()
		section.append(ids)

		self.dataSource.apply(section, to: .main, animatingDifferences: true) { [weak self] in
			self?.collectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
		}
	}

	func selectYear() {
		guard let currentPath = self.collectionView.currentIndexPath(),
			  let prevIndex = self.data.firstIndex(where: { $0.isSelected }),
			  currentPath.row != prevIndex else { return }

		self.data[currentPath.row].isSelected.toggle()
		self.data[prevIndex].isSelected.toggle()

		self.collectionView.scrollToItem(at: currentPath, at: .centeredHorizontally, animated: true)

		let ids = [self.data[currentPath.row].id, self.data[prevIndex].id]

		var snapshot = self.dataSource.snapshot()
		snapshot.reloadItems(ids)

		self.dataSource.apply(snapshot, animatingDifferences: false)

		let updateData = UpdateSelectingModel(prevIndex: prevIndex, index: currentPath.row)
		self.selectHandler?(updateData)
	}

	// MARK: - DataSource

	func createDataSource() -> YearsDataSource {

		let valueRegistratrion = self.createValueCellRegistration()

		return YearsDataSource(collectionView: self.collectionView) {
			[weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in
			
			guard let year = self?.data[indexPath.row] else { return nil }

			let item = ValueItem(value: year.value, isMock: year.isMock, isSelected: year.isSelected, id: year.id)
			return collectionView.dequeueConfiguredReusableCell(using: valueRegistratrion, for: indexPath, item: item)
		}
	}

	// MARK: - Layout

	func createCompositionLayout() -> UICollectionViewLayout {
		
		let sectionProvider = { [weak self] (sectionIndex: Int, environment: NSCollectionLayoutEnvironment)
			-> NSCollectionLayoutSection? in
			let dataCount = self?.data.count ?? 0

			return self?.valueLayout(dataCount: dataCount)
		}

		/// create config for scroll methods will be called.
		let config = UICollectionViewCompositionalLayoutConfiguration()
		config.scrollDirection = .horizontal

		return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
	}
}

extension YearsListCollectionViewCell: ValueCellRegistratable, ValueLayout {}
