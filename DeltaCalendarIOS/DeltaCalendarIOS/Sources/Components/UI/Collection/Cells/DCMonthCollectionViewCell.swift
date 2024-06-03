import UIKit

final class DCMonthCollectionViewCell: UICollectionViewCell {

	typealias DCMonthDataSource = UICollectionViewDiffableDataSource<DCBaseSection, DeltaCalendarItemID>

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

	private var items: [DCalendarDayItem] = [] {
		didSet {
			let ids = self.items.map { $0.id }
			self.setupCollection(by: ids)
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(with data: [DeltaCalendarDay], isWeekendsDisabled: Bool, theme: DeltaCalendarTheme) {
		let colors = DCalendarDayColors(theme: theme)

		let days = self.addExtraEmptyDays(data)

		self.items = days.map {
			let isWeekDay = DCResources.weekends.contains($0.weekday)
			let isDisabled = isWeekDay && isWeekendsDisabled

			return .init(data: $0, colors: colors, isDisabled: isDisabled)
		}
	}
}

// MARK: - CollectionViewDelegate

extension DCMonthCollectionViewCell: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

		var ids = [DeltaCalendarItemID]()

		if let prevSelectedIndex = self.items.firstIndex(where: { $0.isSelected }),
		   prevSelectedIndex != indexPath.row {
			self.items[prevSelectedIndex].isSelected.toggle()

			let id = self.items[prevSelectedIndex].id
			ids.append(id)
		}

		self.items[indexPath.row].isSelected.toggle()

		let id = self.items[indexPath.row].id
		ids.append(id)

		var snapshot = self.dataSource.snapshot()
		snapshot.reloadItems(ids)

		self.dataSource.apply(snapshot, animatingDifferences: true)
	}
}

// MARK: - DaysLayout

extension DCMonthCollectionViewCell: DCalendarDaysLayout {}

private extension DCMonthCollectionViewCell {

	/// Adding empty days for right shifting.
	func addExtraEmptyDays(_ days: [DeltaCalendarDay]) -> [DeltaCalendarDay] {

		let firstWeekDayIndex = DCResources.mondayIndex

		guard let first = days.first, first.weekday != firstWeekDayIndex
		else { return days }

		var currentDays = days

		let dif: Int = first.weekday >= firstWeekDayIndex ? (first.weekday - firstWeekDayIndex) :
		(DCResources.weekdays.count - 1) /// case when sunday is first day of month, at gregorian calendar index is 1.

		(0..<dif).forEach { _ in
			currentDays.insert(.init(title: "", description: "", weekday: 0), at: 0)
		}

		return currentDays
	}

	// MARK: - Configuring

	func setupView() {
		self.contentView.addSubview(self.collectionView)

		self.collectionView.snp.makeConstraints {
			$0.edges.equalTo(self.contentView)
		}
	}

	func setupCollection(by ids: [DeltaCalendarItemID]) {
		guard !ids.isEmpty else { return }

		var snapshot = self.dataSource.snapshot()

		if snapshot.itemIdentifiers.isEmpty {
			snapshot.appendSections([.main])
		}

		snapshot.deleteAllItems()

		self.dataSource.apply(snapshot, animatingDifferences: false)

		var sectionSnapshot = DCSectionSnapshot()
		sectionSnapshot.append(ids)

		self.dataSource.apply(sectionSnapshot, to: .main, animatingDifferences: false)
	}

	// MARK: - Layout

	func createCompositionLayout() -> UICollectionViewLayout {

		let sectionProvider = { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment)
			-> NSCollectionLayoutSection? in

			let frame = self?.contentView.frame ?? .zero

			return self?.DCDaysLayout(parentFrame: frame)
		}

		return UICollectionViewCompositionalLayout(sectionProvider: sectionProvider)
	}

	// MARK: - DataSource

	func createDataSource() -> DCMonthDataSource {

		let dayRegistration = self.createDCDayCellRegistration()

		return DCMonthDataSource(collectionView: self.collectionView) {
			[weak self] (collectionView, indexPath, _) -> UICollectionViewCell? in

			let item = self?.items[indexPath.row]
			return collectionView.dequeueConfiguredReusableCell(using: dayRegistration, for: indexPath, item: item)
		}
	}
}
