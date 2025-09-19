import UIKit

internal final class YearsListCollectionViewCell: UICollectionViewCell {

    typealias YearsDataSource = UICollectionViewDiffableDataSource<BaseSection, ItemID>

    private lazy var collectionView: UICollectionView = {
        $0.backgroundColor = .clear
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.bounces = false
        $0.delegate = self
        $0.decelerationRate = .fast
        $0.collectionViewLayout = self.createCompositionLayout()
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: .init()))

    private var data: [YearItem] = []
    private var colors: Colors = .build()

    private lazy var dataSource: YearsDataSource = {
        self.createDataSource()
    }()

    public var selectHandler: ((UpdateSelectingModel) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with data: [YearItem], colors: Colors) {
        self.data = data
        self.colors = colors

        self.configureCollection(with: data)
    }
}

// MARK: - UICollectionViewDelegate

extension YearsListCollectionViewCell: UICollectionViewDelegate {

    func collectionView(
        _ collectionView: UICollectionView,
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: Resources.feedbackVal)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let year = self.data[indexPath.row]

        guard !year.isMock else { return }

        self.selectYear(at: indexPath.row)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate, let currentPath = self.collectionView.currentIndexPath() else { return }
        self.selectYear(at: currentPath.row)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let currentPath = self.collectionView.currentIndexPath() else { return }
        self.selectYear(at: currentPath.row)
    }
}

private extension YearsListCollectionViewCell {

    // MARK: - Setting logic

    func setupView() {
        self.contentView.addSubview(self.collectionView)

        self.collectionView.snp.makeConstraints { $0.edges.equalTo(self.contentView) }
    }

    func configureCollection(with data: [YearItem]) {
        guard !data.isEmpty, let selectedRow = self.data.firstIndex(where: { $0.isSelected }) else { return }

        let isUpdating = !self.dataSource.snapshot().sectionIdentifiers.isEmpty
        let selectedIndexPath = IndexPath(row: selectedRow, section: BaseSection.main.rawValue)
        var snapshot = self.dataSource.snapshot()

        defer {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.collectionView.scrollToItem(at: selectedIndexPath, at: .centeredHorizontally, animated: false)
            }
        }

        guard !isUpdating else {
            snapshot.reloadSections([.main])
            self.dataSource.apply(snapshot, animatingDifferences: false)
            return
        }

        snapshot.appendSections([.main])
        self.dataSource.apply(snapshot, animatingDifferences: false)

        let ids = self.data.map { $0.id }
        var section = SectionSnapshot()

        section.append(ids)

        self.dataSource.apply(section, to: .main, animatingDifferences: true)
    }

    func selectYear(at index: Int) {
        guard let prevIndex = self.data.firstIndex(where: { $0.isSelected }), index != prevIndex else { return }

        self.data[index].isSelected.toggle()
        self.data[prevIndex].isSelected.toggle()

        let currentPath = IndexPath(row: index, section: BaseSection.main.rawValue)
        self.collectionView.scrollToItem(at: currentPath, at: .centeredHorizontally, animated: true)

        let ids = [self.data[index].id, self.data[prevIndex].id]

        var snapshot = self.dataSource.snapshot()
        snapshot.reloadItems(ids)

        self.dataSource.apply(snapshot, animatingDifferences: false)

        let updateData = UpdateSelectingModel(prevIndex: prevIndex, index: index)
        self.selectHandler?(updateData)
    }

    // MARK: - DataSource

    func createDataSource() -> YearsDataSource {
        let valueRegistratrion = self.createValueCellRegistration(colors: self.colors)

        return YearsDataSource(collectionView: self.collectionView) { [weak self] (collectionView, indexPath, _)
            -> UICollectionViewCell? in
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
