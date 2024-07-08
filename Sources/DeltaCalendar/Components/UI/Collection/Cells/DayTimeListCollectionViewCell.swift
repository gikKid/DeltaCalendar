import UIKit

internal final class DayTimeListCollectionViewCell: UICollectionViewCell {

    typealias DayTimeDataSource = UICollectionViewDiffableDataSource<Section, ItemID>

    private lazy var collectionView: UICollectionView = {
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.bounces = false
        $0.decelerationRate = .fast
        $0.delegate = self
        $0.collectionViewLayout = self.compositionLayout()
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: .init()))

    private lazy var dataSource: DayTimeDataSource = {
        self.createDataSource()
    }()

    private var colors: Colors = .def()
    private var data = [DayTime]()
    private let noDataItem: ValueItem = {
        ValueItem.buildNoData(text: TextResources.noAvailableTime)
    }()

    public var selectHandler: ((UpdateSelectingModel) -> Void)?

    enum Section {
        case main, noData

        var index: Int { 0 }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with time: [DayTime], colors: Colors) {
        self.colors = colors
        self.data = time

        guard !time.isEmpty else {
            self.setNoDataCollection(); return
        }

        self.setCollection(with: time)
    }
}

// MARK: - UICollectionViewDelegate

extension DayTimeListCollectionViewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: Resources.feedbackVal)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectTime(at: indexPath.row)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate, let currentPath = self.collectionView.currentIndexPath()
        else { return }

        self.selectTime(at: currentPath.row)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let currentPath = self.collectionView.currentIndexPath() else { return }
        self.selectTime(at: currentPath.row)
    }
}

private extension DayTimeListCollectionViewCell {

    // MARK: - Setup logic

    func setupView() {
        self.contentView.addSubview(self.collectionView)

        self.collectionView.snp.makeConstraints { $0.edges.equalTo(self.contentView) }
    }

    func setNoDataCollection() {
        var snapshot = self.dataSource.snapshot()

        guard !snapshot.sectionIdentifiers.contains(.noData) else { return }

        snapshot.deleteSections([.main])
        snapshot.appendSections([.noData])

        self.dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            guard let id = self?.noDataItem.id else { return }

            var sectionSnapshot = SectionSnapshot()
            sectionSnapshot.append([id])

            self?.dataSource.apply(sectionSnapshot, to: .noData, animatingDifferences: true)
        }
    }

    func setCollection(with data: [DayTime]) {

        var snapshot = self.dataSource.snapshot()

        let sections = snapshot.sectionIdentifiers
        sections.contains(.noData) ? snapshot.deleteSections([.noData]) : ()
        sections.contains(.main) ? () : snapshot.appendSections([.main])

        self.dataSource.apply(snapshot, animatingDifferences: true) { [weak self] in
            let ids = data.map { $0.id }

            var sectionSnapshot = SectionSnapshot()
            sectionSnapshot.append(ids)

            self?.dataSource.apply(sectionSnapshot, to: .main, animatingDifferences: true) {
                self?.scrollToSelectedItem(data)
            }
        }
    }

    func scrollToSelectedItem(_ time: [DayTime]) {
        guard let selectedRow = time.firstIndex(where: { $0.isSelected }) else { return }

        let selectedPath = IndexPath(row: selectedRow, section: Section.main.index)
        self.collectionView.scrollToItem(at: selectedPath, at: .centeredHorizontally, animated: true)

        self.selectHandler?(.init(prevIndex: 0, index: selectedRow))
    }

    func selectTime(at index: Int) {
        guard let prevIndex = self.data.firstIndex(where: { $0.isSelected }), index != prevIndex
        else { return }

        self.data[index].isSelected.toggle()
        self.data[prevIndex].isSelected.toggle()

        let currentPath = IndexPath(row: index, section: Section.main.index)
        self.collectionView.scrollToItem(at: currentPath, at: .centeredHorizontally, animated: true)

        let ids = [self.data[index].id, self.data[prevIndex].id]

        var snapshot = self.dataSource.snapshot()
        snapshot.reloadItems(ids)

        self.dataSource.apply(snapshot, animatingDifferences: false)

        let updateModel = UpdateSelectingModel(prevIndex: prevIndex, index: index)
        self.selectHandler?(updateModel)
    }

    // MARK: - DataSource

    func createDataSource() -> DayTimeDataSource {

        let cellRegistration = self.createValueCellRegistration(colors: self.colors)

        return DayTimeDataSource(collectionView: self.collectionView) {
            [weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in

            guard let data = self?.data, !data.isEmpty else {
                let item = self?.noDataItem
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }

            let time = data[indexPath.row]
            let item = ValueItem(value: time.title, isMock: false, isSelected: time.isSelected, id: time.id)

            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }

    // MARK: - Layout

    func compositionLayout() -> UICollectionViewLayout {

        let sectionProvider = { [weak self] (sectionIndex: Int, collectionEnvironment: NSCollectionLayoutEnvironment)
            -> NSCollectionLayoutSection? in

            guard let data = self?.data, !data.isEmpty else {
                return self?.noDataLayout()
            }

            return self?.valueLayout(dataCount: data.count)
        }

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider, configuration: config)
    }

    func noDataLayout() -> NSCollectionLayoutSection {

        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                          heightDimension: .fractionalHeight(1))

        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])

        return NSCollectionLayoutSection(group: group)
    }
}

extension DayTimeListCollectionViewCell: ValueCellRegistratable, ValueLayout {}
