import Foundation
import UIKit

final class DCMonthCollectionReusableView: UICollectionReusableView {

	private let feedbackVal: CGFloat = 0.5

	private let monthLabel: UILabel = {
		let size = DCTextSizeResources.big

		let label = UILabel()
		label.textAlignment = .center
		label.font = UIFont(name: DCFontsResources.segoeBold, size: size)
		return label
	}()
	private let nextButton: UIButton = {
		let imgConfig = UIImage.SymbolConfiguration(scale: .large)
		let image = DCImageResources.chevronRight?.withConfiguration(imgConfig)

		let button = UIButton()
		button.setImage(image, for: .normal)
		return button
	}()
	private let prevButton: UIButton = {
		let imgConfig = UIImage.SymbolConfiguration(scale: .large)
		let image = DCImageResources.chevronLeft?.withConfiguration(imgConfig)

		let button = UIButton()
		button.setImage(image, for: .normal)
		return button
	}()
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		return stackView
	}()

	public var eventHandler: ((Event) -> Void)?

	enum Event {
		case nextMonth, prevMonth
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func configure(monthTitle: String, theme: DeltaCalendarTheme) {
		self.monthLabel.text = monthTitle

		let color = theme == .dark ? DCColorsResources.textLightColor :
		DCColorsResources.textDarkColor

		self.monthLabel.textColor = color
		self.nextButton.imageView?.tintColor = color
		self.prevButton.imageView?.tintColor = color
	}
}

private extension DCMonthCollectionReusableView {

	func setupView() {
		self.addSubview(self.monthLabel)
		self.addSubview(self.nextButton)
		self.addSubview(self.prevButton)
		self.addSubview(self.stackView)

		self.setConstraints()

		self.prevButton.addTarget(self, action: #selector(self.prevBtnTapped), for: .touchUpInside)
		self.nextButton.addTarget(self, action: #selector(self.nextBtnTapped), for: .touchUpInside)

		let width = self.frame.width / CGFloat(DCResources.weekdays.count)
		self.setWeekdays(weekdayWidth: width)
	}

	func setConstraints() {

		let xOffset = DCSpaceResources.moreMid

		self.prevButton.snp.makeConstraints {
			$0.top.equalTo(self)
			$0.leading.equalTo(self).offset(xOffset)
			$0.width.height.equalTo(DCHeightResources.icon)
		}

		self.nextButton.snp.makeConstraints {
			$0.top.equalTo(self)
			$0.trailing.equalTo(self).offset(-xOffset)
			$0.width.height.equalTo(self.prevButton)
		}

		let labelOffset = DCSpaceResources.small

		self.monthLabel.snp.makeConstraints {
			$0.centerY.equalTo(self.prevButton)
			$0.centerX.equalTo(self)
			$0.leading.lessThanOrEqualTo(self.prevButton.snp.trailing).offset(labelOffset)
			$0.trailing.lessThanOrEqualTo(self.nextButton.snp.leading).offset(-labelOffset)
		}

		self.stackView.snp.makeConstraints {
			$0.top.equalTo(self.monthLabel.snp.bottom).offset(DCSpaceResources.moreMid)
			$0.leading.trailing.bottom.equalTo(self)
		}
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

	@objc func prevBtnTapped(_ sender: UIButton) {
		UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: self.feedbackVal)
		self.eventHandler?(.prevMonth)
	}

	@objc func nextBtnTapped(_ sender: UIButton) {
		UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: self.feedbackVal)
		self.eventHandler?(.nextMonth)
	}
}
