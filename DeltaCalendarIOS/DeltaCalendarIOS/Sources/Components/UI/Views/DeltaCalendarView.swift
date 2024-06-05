import UIKit
import Combine

protocol DeltaCalendarViewDelegate {
	func dateSelected(_ date: Date)
}

final class DeltaCalendarView: UIView {

	typealias DeltaCalendarDataSource = UICollectionViewDiffableDataSource<DCalendarSection, DeltaCalendarItemID>

	private var delegate: DeltaCalendarViewDelegate?
	private var subscriptions = Set<AnyCancellable>()

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
		let startData = DCStartModel(theme: .light, isWeekendsDisabled: false,
									 isPastDaysDisabled: false, isShowTime: false,
									 isPickingYear: false)
		return .init(with: startData)
	}()
	private lazy var presenter: DeltaCalendarViewPresentable = {
		DeltaCalendarViewPresenter(self.dataSource, self.viewModel)
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func disableWeekends(isDisable: Bool) {
		self.presenter.disableWeekendsChanged(isDisable: isDisable)
	}

	func disablePastDays(isDisable: Bool) {
		self.presenter.disablePastDays(isDisable: isDisable)
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

// MARK: - MonthLayout

extension DeltaCalendarView: DCalendarMonthLayout {
	func monthTitle(at: IndexPath) -> String {
		self.presenter.monthTitle()
	}

	func nextMonthTapped() {
		self.presenter.makeNextMonth()
	}

	func prevMonthTapped() {
		self.presenter.makePrevMonth()
	}

	func daySelected(at index: Int) {
		self.presenter.updateDaySelecting(at: index)
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
			.sink { [weak self] indexPath in
				self?.scrollTo(at: indexPath, deadline: .now(), animated: true)
			}.store(in: &self.subscriptions)

		self.presenter.selectedDatePublisher.sink { [weak self] date in
			guard let date else { return }
			self?.delegate?.dateSelected(date)
		}.store(in: &self.subscriptions)

		self.presenter.setupDS() { [weak self] in
			guard let indexPath = self?.presenter.currentMonth()
			else { return }

			self?.scrollTo(at: indexPath, deadline: .now() + 0.1, animated: false)
		}
	}

	func scrollTo(at item: IndexPath, deadline: DispatchTime, animated: Bool) {
		DispatchQueue.main.asyncAfter(deadline: deadline) {
			self.collectionView.isPagingEnabled = false // bug at iOS 14
			self.collectionView.scrollToItem(at: item, at: .centeredHorizontally, animated: animated)
			self.collectionView.isPagingEnabled = true
		}
	}

	func setDefaultColors() {
		self.backgroundColor = self.viewModel.startData.theme == .dark ? DCColorsResources.darkBackColor
		: DCColorsResources.lightBackColor
	}

	func setConstraints() {
		self.collectionView.snp.makeConstraints {
			$0.edges.equalTo(self)
		}
	}

	// MARK: - DataSource

	func createDataSource() -> DeltaCalendarDataSource {

		let monthRegistration = self.createDCMonthCellRegistration()

		return DeltaCalendarDataSource(collectionView: self.collectionView) {
			[weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in

			let item = self?.presenter.month(at: indexPath.row)
			return collectionView.dequeueConfiguredReusableCell(using: monthRegistration, for: indexPath, item: item)
//			guard let section = self?.viewModel.section(at: indexPath.section)
//			else { return nil }
//
//			switch section {
//			case .days:
//				let item = self?.viewModel.month(at: indexPath.row)
//				return collectionView.dequeueConfiguredReusableCell(using: monthRegistration, for: indexPath, item: item)
//			default: return nil
//			}
		}
	}

	func setWeekdaysHeader() {

		let headerRegistration = self.createMonthHeaderRegistration(self.viewModel.startData.theme)

		self.dataSource.supplementaryViewProvider = { [weak self] (_, _, indexPath) in
			return self?.collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
		}
	}

	// MARK: - Layout

	func compositionLayout() -> UICollectionViewLayout {

		let sectionProvider = { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment)
			-> NSCollectionLayoutSection? in

			return self?.DCMonthLayout()
//			guard let section = self?.viewModel.section(at: sectionIndex) else { return nil }
//
//			let frame = self?.frame ?? .zero
//
//			switch section {
//			case .days: return self?.DCMonthLayout(parentFrame: frame)
//			default: 	return nil
//			}
		}

		return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
	}
}
