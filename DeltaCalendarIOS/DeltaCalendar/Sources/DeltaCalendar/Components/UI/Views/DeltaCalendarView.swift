import UIKit
import Combine
import SnapKit

protocol DeltaCalendarViewDelegate {
	func dateSelected(_ date: Date)
}

final class DeltaCalendarView: UIView {

	typealias DeltaCalendarDataSource = UICollectionViewDiffableDataSource<Section, ItemID>

	public var delegate: DeltaCalendarViewDelegate?
	private var subscriptions = Set<AnyCancellable>()
	private let startData: StartModel

	private weak var monthHeader: MonthCollectionReusableView?
	private lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
		collectionView.backgroundColor = .clear
		collectionView.bounces = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.showsVerticalScrollIndicator = false
		collectionView.delegate = self
		collectionView.collectionViewLayout = self.compositionLayout()
		return collectionView
	}()
	private lazy var dataSource: DeltaCalendarDataSource = {
		self.createDataSource()
	}()
	private lazy var viewModel: DeltaCalendarViewModel = {
		.init(with: self.startData)
	}()
	private lazy var presenter: DeltaCalendarViewPresentable = {
		DeltaCalendarViewPresenter(self.dataSource, self.viewModel)
	}()

	init(weekendsOff: Bool = false, pastDaysOff: Bool = false,
		 theme: Theme = .light, pickingYearData: PickingYearModel? = nil,
		 showTimeData: ShowTimeModel? = nil) {

		self.startData = .init(theme: theme, weekendsOff: weekendsOff, pastDaysOff: pastDaysOff,
							   pickingYearData: pickingYearData, showTimeData: showTimeData)

		super.init(frame: .zero)

		self.setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - CollectionViewDelegate

extension DeltaCalendarView: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, 
						forItemAt indexPath: IndexPath) {
		guard let currentIndexPath = self.collectionView.currentIndexPath() else { return }

		self.presenter.itemScrolled(currentItem: currentIndexPath)
	}
}

// MARK: - YearsListCellRegistratable

extension DeltaCalendarView: YearsListCellRegistratable {
	func yearSelected(_ data: UpdateSelectingModel) {
		self.presenter.yearSelected(data)
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

private extension DeltaCalendarView {

	// MARK: - Setting

	func setupView() {
		self.setDefaultColors()

		self.addSubview(self.collectionView)

		self.setConstraints()
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

		self.presenter.setupDS(with: self.startData)

		guard let indexPath = self.presenter.currentMonth() else { return }
		self.scrollTo(at: indexPath, deadline: .now() + 0.1, animated: false)
	}

	func scrollToMonth(to index: Int) {
		guard let section = self.dataSource.snapshot().indexOfSection(.month)
		else { return }

		let indexPath = IndexPath(row: index, section: section)
		self.scrollTo(at: indexPath, deadline: .now(), animated: true)

		let isSwitchingOff = self.startData.pickingYearData != nil
		let title = self.monthTitle(at: indexPath.row)

		self.monthHeader?.configure(monthTitle: title, theme: self.startData.theme,
									isSwitchingOff: isSwitchingOff)
	}

	func scrollTo(at item: IndexPath, deadline: DispatchTime, animated: Bool) {
		DispatchQueue.main.asyncAfter(deadline: deadline) {
			self.collectionView.isPagingEnabled = false // bug at iOS 14
			self.collectionView.scrollToItem(at: item, at: .centeredHorizontally, animated: animated)
			self.collectionView.isPagingEnabled = true
		}
	}

	func setDefaultColors() {
		self.backgroundColor = self.startData.theme == .dark ? ColorsResources.darkBackColor
		: ColorsResources.lightBackColor
	}

	func setConstraints() {
		self.collectionView.snp.makeConstraints { $0.edges.equalTo(self) }
	}

	// MARK: - DataSource

	func createDataSource() -> DeltaCalendarDataSource {

		let monthRegistration = self.createMonthCellRegistration()
		let yearsRegistration = self.createYearsCellRegistration()
		let dayTimeRegistration = self.createDayTimeRegistration()

		return DeltaCalendarDataSource(collectionView: self.collectionView) {
			[weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in

			guard let startData = self?.startData,
				  let section = self?.presenter.section(at: indexPath.section, startData: startData)
			else { return nil }

			switch section {
			case .year:
				let item = self?.presenter.yearsItem
				return collectionView.dequeueConfiguredReusableCell(using: yearsRegistration, for: indexPath, item: item)
			case .month:
				let item = self?.presenter.month(at: indexPath.row)
				return collectionView.dequeueConfiguredReusableCell(using: monthRegistration, for: indexPath, item: item)
			case .time:
				let item = self?.presenter.dayTimeData()
				return collectionView.dequeueConfiguredReusableCell(using: dayTimeRegistration, for: indexPath, item: item)
			}
		}
	}

	func setWeekdaysHeader() {

		let isSwitchingOff = self.startData.pickingYearData != nil
		let headerRegistration = self.createMonthHeaderRegistration(isSwitchingOff: isSwitchingOff,
																	theme: self.startData.theme)

		self.dataSource.supplementaryViewProvider = { [weak self] (_, _, indexPath) in
			let header = self?.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
			self?.monthHeader = header
			return header
		}
	}

	// MARK: - Layout

	func compositionLayout() -> UICollectionViewLayout {

		let sectionProvider = { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment)
			-> NSCollectionLayoutSection? in

			guard let startData = self?.startData,
				  let section = self?.presenter.section(at: sectionIndex, startData: startData) 
			else { return nil }

			let frame = self?.frame ?? .zero

			switch section {
			case .year, .time: return self?.valueListLayout()
			case .month: 	   return self?.monthLayout(parentFrame: frame)
			}
		}

		return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
	}
}

extension DeltaCalendarView: MonthLayout, ValueListLayout {}
