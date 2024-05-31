import Foundation
import UIKit

final class DCWeekDaysCollectionReusableView: UICollectionReusableView {

	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		return stackView
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private extension DCWeekDaysCollectionReusableView {

	func setupView() {
		self.addSubview(self.stackView)

		self.stackView.snp.makeConstraints { $0.edges.equalTo(self) }

		let width = self.frame.width / CGFloat(DCResources.weekdays.count)
		self.setWeekdays(weekdayWidth: width)
	}

	func setWeekdays(weekdayWidth: CGFloat) {
		let weekdays = DCResources.weekdays

		weekdays.forEach {
			let label = self.createLabel(text: $0)
			self.stackView.addArrangedSubview(label)

			label.snp.makeConstraints { $0.width.equalTo(weekdayWidth) }
		}
	}

	func createLabel(text: String) -> UILabel {
		let label = UILabel()
		label.text = text
		label.textAlignment = .center
		label.textColor = DCColorsResources.secondaryTextColor
		label.font = UIFont(name: DCFontsResources.segoe, size: DCTextSizeResources.small)
		return label
	}
}
