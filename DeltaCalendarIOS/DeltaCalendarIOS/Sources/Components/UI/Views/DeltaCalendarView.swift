import UIKit
import Combine

final class DeltaCalendarView: UIView {

	typealias DeltaCalendarDataSource = UICollectionViewDiffableDataSource<DCalendarSection, DeltaCalendarItemID>

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
	private let confirmButton: UIButton = {
		let size = DCTextSizeResources.mid

		let button = UIButton()
		button.setTitle(DCTextResources.confirm, for: .normal)
		button.titleLabel?.textAlignment = .center
		button.titleLabel?.font = UIFont(name: DCFontsResources.segoe, size: size)
		button.layer.cornerRadius = DCRadiusResources.button
		return button
	}()
	private lazy var dataSource: DeltaCalendarDataSource = {
		self.createDataSource()
	}()
	private lazy var viewModel: DeltaCalendarViewModel = {
		.init(theme: .light, isShowTime: false, isWeekendsDisabled: false)
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(confirmText: String) {
		self.confirmButton.setTitle(confirmText, for: .normal)
	}

	func updateConfirmBtn(text: String, font: UIFont?) {
		self.confirmButton.setTitle(text, for: .normal)
		self.confirmButton.titleLabel?.font = font
	}
}

// MARK: - CollectionViewDelegate

extension DeltaCalendarView: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, 
						forItemAt indexPath: IndexPath) {
		guard let currentIndexPath = self.collectionView.currentIndexPath() else { return }

		self.viewModel.itemScrolled(currentItem: currentIndexPath, at: self.dataSource)
	}
}

// MARK: - MonthLayout

extension DeltaCalendarView: DCalendarMonthLayout {
	func monthTitle(at: IndexPath) -> String {
		self.viewModel.monthTitle(at: self.dataSource)
	}

	func nextMonthTapped() {
		self.viewModel.makeNextMonth(at: self.dataSource)
	}

	func prevMonthTapped() {
		self.viewModel.makePrevMonth(at: self.dataSource)
	}
}

private extension DeltaCalendarView {

	// MARK: - Setting

	func setupView() {
		self.setDefaultColors()

		self.addSubview(self.confirmButton)
		self.addSubview(self.collectionView)

		self.setConstraints()
		self.setWeekdaysHeader()

		self.viewModel.monthIndexPublisher
			.dropFirst()
			.sink { [weak self] indexPath in
				self?.scrollTo(at: indexPath, deadline: .now(), animated: true)
			}.store(in: &self.subscriptions)

		self.viewModel.setupDataSource(at: self.dataSource) { [weak self] in
			guard let dataSource = self?.dataSource,
				  let indexPath = self?.viewModel.currentMonth(at: dataSource)
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

		self.confirmButton.setTitleColor(DCColorsResources.activeBtnTextColor, for: .normal)
		self.confirmButton.backgroundColor = DCColorsResources.activeBtnBackColor
	}

	func setConstraints() {
		self.collectionView.snp.makeConstraints {
			$0.top.leading.trailing.equalTo(self)
			$0.bottom.equalTo(self.confirmButton.snp.top).offset(-DCSpaceResources.mid)
		}

		self.confirmButton.snp.makeConstraints {
			$0.height.equalTo(DCHeightResources.button)
			$0.bottom.leading.trailing.equalTo(self).inset(DCSpaceResources.moreMid)
		}
	}

	// MARK: - DataSource

	func createDataSource() -> DeltaCalendarDataSource {

		let monthRegistration = self.createDCMonthCellRegistration(self.viewModel.startData.theme)

		return DeltaCalendarDataSource(collectionView: self.collectionView) {
			[weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in

			let item = self?.viewModel.month(at: indexPath.row)
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
