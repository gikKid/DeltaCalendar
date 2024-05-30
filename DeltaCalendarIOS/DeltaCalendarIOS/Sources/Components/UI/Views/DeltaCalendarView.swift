import UIKit

final class DeltaCalendarView: UIView {

	typealias DeltaCalendarDataSource = UICollectionViewDiffableDataSource<DCalendarSection, DeltaCalendarItemID>

	private lazy var collectionView: UICollectionView = {
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: .init())
		collectionView.backgroundColor = .clear
		collectionView.bounces = false
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.showsVerticalScrollIndicator = false
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
		DeltaCalendarViewModel()
	}()

	convenience init(theme: DCalendarTheme, isShowYear: Bool, isShowTime: Bool) {
		self.init(frame: .zero)
		self.viewModel.update(theme: theme, isShowYear: isShowYear, isShowTime: isShowTime)
	}

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

// MARK: - MonthLayout

extension DeltaCalendarView: DCalendarMonthLayout {

}

private extension DeltaCalendarView {

	// MARK: - Setting

	func setupView() {
		self.setDefaultColors()

		self.addSubview(self.confirmButton)
		self.addSubview(self.collectionView)

		self.setConstraints()
	}

	func setDefaultColors() {
		self.backgroundColor = self.viewModel.theme == .dark ? UIColor(named: DColorsResources.darkBackColor)
		: UIColor(named: DColorsResources.lightBackColor)

		self.confirmButton.setTitleColor(UIColor(named: DColorsResources.activeBtnTextColor), for: .normal)
		self.confirmButton.backgroundColor = UIColor(named: DColorsResources.activeBtnBackColor)
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

		let monthRegistration = self.createDCMonthCellRegistration()

		return DeltaCalendarDataSource(collectionView: self.collectionView) {
			[weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in

			guard let section = self?.viewModel.section(at: indexPath.section)
			else { return nil }

			switch section {
			case .days:
				let item = self?.viewModel.month(at: indexPath.row)
				return collectionView.dequeueConfiguredReusableCell(using: monthRegistration, for: indexPath, item: item)
			default: return nil
			}
		}
	}

	// MARK: - Layout

	func compositionLayout() -> UICollectionViewLayout {

		let sectionProvider = { [weak self] (sectionIndex: Int, sectionEnvironment: NSCollectionLayoutEnvironment)
			-> NSCollectionLayoutSection? in

			guard let section = self?.viewModel.section(at: sectionIndex) else { return nil }

			let frame = self?.frame ?? .zero

			switch section {
			case .days: return self?.DCMonthLayout(parentFrame: frame)
			default: 	return nil
			}
		}

		return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
	}
}
