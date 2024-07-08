import UIKit
import Combine
import SnapKit

public protocol DeltaCalendarViewDelegate {
    /// - Returns: Date formatted yyyy-MM-dd HH:mm:ssZ
    func dateSelected(_ date: Date)
}

public final class DeltaCalendarView: UIView {

    typealias DeltaCalendarDataSource = UICollectionViewDiffableDataSource<Section, ItemID>

    public var delegate: DeltaCalendarViewDelegate?
    private var subscriptions = Set<AnyCancellable>()
    private let startData: StartModel

    private weak var monthHeader: MonthCollectionReusableView?
    private lazy var collectionView: UICollectionView = {
        $0.backgroundColor = .clear
        $0.bounces = false
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = false
        $0.delegate = self
        $0.collectionViewLayout = self.compositionLayout()
        return $0
    }(UICollectionView(frame: .zero, collectionViewLayout: .init()))

    private lazy var dataSource: DeltaCalendarDataSource = {
        self.createDataSource()
    }()
    private lazy var viewModel: DeltaCalendarViewModel = {
        .init(with: self.startData)
    }()
    private lazy var presenter: DeltaCalendarViewPresentable = {
        DeltaCalendarViewPresenter(self.dataSource, self.viewModel)
    }()

    public init(pickingYearData: PickingYearModel, showTimeData: ShowTimeModel,
                colors: Colors, disablePreviousDays: Bool) {

        self.startData = .init(pickingYearData: pickingYearData, showTimeData: showTimeData,
                               colors: colors, disablePreviousDays: disablePreviousDays)

        super.init(frame: .zero)

        self.setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - CollectionViewDelegate

extension DeltaCalendarView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
                               forItemAt indexPath: IndexPath) {
        guard let currentIndexPath = self.collectionView.currentIndexPath() else { return }

        self.presenter.itemScrolled(currentItem: currentIndexPath)
    }
}

// MARK: - YearsListCellRegistratable

extension DeltaCalendarView: YearsListCellRegistratable {
    func yearSelected(_ data: UpdateSelectingModel) {
        self.presenter.yearSelected(updateData: data, month: 0)
    }
}

// MARK: - MonthHeaderRegistratable

extension DeltaCalendarView: MonthHeaderRegistratable {
    func monthTitle(at index: Int) -> String {
        self.presenter.month(at: index)?.title ?? "-"
    }

    func nextMonthTapped() {
        self.presenter.makeNextMonth()
    }

    func prevMonthTapped() {
        self.presenter.makePrevMonth()
    }
}

// MARK: - MonthCellRegistratable

extension DeltaCalendarView: MonthCellRegistratable {
    func daySelected(at index: Int) {
        self.presenter.updateDaySelecting(at: index)
    }
}

// MARK: - DayTimeCellRegistratable

extension DeltaCalendarView: DayTimeCellRegistratable {
    func timeSelected(_ data: UpdateSelectingModel) {
        guard let date = self.presenter.timeSelected(data) else { return }
        self.delegate?.dateSelected(date)
    }
}

// MARK: - PresenterDelegate

extension DeltaCalendarView: DeltaCalendarViewPresenterDelegate {
    func calendarDSConfigured() {
        guard let indexPath = self.presenter.currentMonth() else { return }

        self.scrollTo(at: indexPath, animated: true)
    }
}

private extension DeltaCalendarView {

    // MARK: - Setting

    func setupView() {
        self.backgroundColor = self.startData.colors.background

        self.addSubview(self.collectionView)

        self.collectionView.snp.makeConstraints { $0.edges.equalTo(self) }

        self.setWeekdaysHeader()

        self.presenter.monthIndexPublisher
            .dropFirst()
            .sink { [weak self] index in
                self?.scrollToMonth(to: index)
            }.store(in: &self.subscriptions)

        self.presenter.selectedDatePublisher.sink { [weak self] date in
            guard let date else { return }
            self?.delegate?.dateSelected(date)
        }.store(in: &self.subscriptions)

        self.presenter.delegate = self

        self.presenter.showConfiguring()
    }

    func scrollToMonth(to index: Int) {
        guard let section = self.dataSource.snapshot().indexOfSection(.month)
        else { return }

        let indexPath = IndexPath(row: index, section: section)
        self.scrollTo(at: indexPath, animated: true)

        let title = self.monthTitle(at: indexPath.row)

        self.monthHeader?.configure(monthTitle: title, textColor: self.startData.colors.text)
    }

    func scrollTo(at item: IndexPath, animated: Bool) {
        DispatchQueue.main.async {
            self.collectionView.isPagingEnabled = false // bug at iOS 14
            self.collectionView.scrollToItem(at: item, at: .centeredHorizontally, animated: animated)
            self.collectionView.isPagingEnabled = true
        }
    }

    // MARK: - DataSource

    func createDataSource() -> DeltaCalendarDataSource {

        let monthRegistr = self.createMonthCellRegistration(colors: self.startData.colors)
        let yearsRegistr = self.createYearsCellRegistration(colors: self.startData.colors)
        let dayTimeRegistr = self.createDayTimeRegistration(colors: self.startData.colors)
        let configRegistr = self.createMockLoadingCellRegistration()

        return DeltaCalendarDataSource(collectionView: self.collectionView) {
            [weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in

            let isConfiguring = self?.viewModel.isConfiguring() ?? true

            guard let section = Section(index: indexPath.section, isConfiguring: isConfiguring) else { return nil }

            switch section {
            case .year:
                let item = self?.presenter.yearsItem
                return collectionView.dequeueConfiguredReusableCell(using: yearsRegistr, for: indexPath, item: item)
            case .month:
                let item = self?.presenter.month(at: indexPath.row)
                return collectionView.dequeueConfiguredReusableCell(using: monthRegistr, for: indexPath, item: item)
            case .time:
                let item = self?.presenter.dayTimeData()
                return collectionView.dequeueConfiguredReusableCell(using: dayTimeRegistr, for: indexPath, item: item)
            case .loading:
                let item = self?.presenter.mockConfigItem
                return collectionView.dequeueConfiguredReusableCell(using: configRegistr, for: indexPath, item: item)
            }
        }
    }

    func setWeekdaysHeader() {
        let headerRegistr = self.createMonthHeaderRegistration(textColor: self.startData.colors.text)

        self.dataSource.supplementaryViewProvider = { [weak self] (_, _, indexPath) in
            let header = self?.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistr, for: indexPath)
            self?.monthHeader = header
            return header
        }
    }

    // MARK: - Layout

    func compositionLayout() -> UICollectionViewLayout {

        let sectionProvider = { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment)
            -> NSCollectionLayoutSection? in

            let isConfiguring = self?.viewModel.isConfiguring() ?? true

            guard let section = Section(index: sectionIndex, isConfiguring: isConfiguring) else { return nil }

            let frame = self?.frame ?? .zero

            switch section {
            case .year, .time, .loading:
                return self?.valueListLayout()
            case .month:
                return self?.monthLayout(parentFrame: frame)

            }
        }

        return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
    }
}

extension DeltaCalendarView: MonthLayout, ValueListLayout, MockLoadingRegistrable {}
