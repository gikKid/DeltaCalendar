import UIKit

internal final class MonthCollectionReusableView: UICollectionReusableView {

	private let monthLabel: UILabel = {
		let size = TextSizeResources.big

		$0.textAlignment = .center
		$0.font = UIFont.systemFont(ofSize: size, weight: .bold)
		return $0
	}(UILabel())

	private lazy var nextButton: UIButton = {
		let imgConfig = UIImage.SymbolConfiguration(scale: .large)
		let image = ImageResources.chevronRight?.withConfiguration(imgConfig)

        $0.addTarget(self, action: #selector(self.nextBtnTapped), for: .touchUpInside)
		$0.setImage(image, for: .normal)
		return $0
	}(UIButton())

	private lazy var prevButton: UIButton = {
		let imgConfig = UIImage.SymbolConfiguration(scale: .large)
		let image = ImageResources.chevronLeft?.withConfiguration(imgConfig)

        $0.addTarget(self, action: #selector(self.prevBtnTapped), for: .touchUpInside)
		$0.setImage(image, for: .normal)
		return $0
	}(UIButton())

	private let stackView: UIStackView = {
		$0.axis = .horizontal
		return $0
	}(UIStackView())

    private var tapTimer: Timer?
    private var timerValid: Bool {
        self.tapTimer?.isValid ?? false
    }

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

    func configure(monthTitle: String, textColor: UIColor) {
		self.monthLabel.text = monthTitle

		self.monthLabel.textColor = textColor
		self.nextButton.imageView?.tintColor = textColor
		self.prevButton.imageView?.tintColor = textColor
	}
}

private extension MonthCollectionReusableView {

	func setupView() {
		self.addSubview(self.monthLabel)
		self.addSubview(self.nextButton)
		self.addSubview(self.prevButton)
		self.addSubview(self.stackView)

		self.setConstraints()

		let width = self.frame.width / CGFloat(Resources.weekdays.count)
		self.setWeekdays(weekdayWidth: width)
	}

	func setConstraints() {

		let xOffset = SpaceResources.moreMid

		self.prevButton.snp.makeConstraints {
			$0.top.equalTo(self)
			$0.leading.equalTo(self).offset(xOffset)
			$0.width.height.equalTo(HeightResources.icon)
		}

		self.nextButton.snp.makeConstraints {
			$0.top.equalTo(self)
			$0.trailing.equalTo(self).offset(-xOffset)
			$0.width.height.equalTo(self.prevButton)
		}

		let labelOffset = SpaceResources.small

		self.monthLabel.snp.makeConstraints {
			$0.centerY.equalTo(self.prevButton)
			$0.centerX.equalTo(self)
			$0.leading.lessThanOrEqualTo(self.prevButton.snp.trailing).offset(labelOffset)
			$0.trailing.lessThanOrEqualTo(self.nextButton.snp.leading).offset(-labelOffset)
		}

		self.stackView.snp.makeConstraints {
			$0.top.equalTo(self.monthLabel.snp.bottom).offset(SpaceResources.moreMid)
			$0.leading.trailing.bottom.equalTo(self)
		}
	}

	func setWeekdays(weekdayWidth: CGFloat) {
		let weekdays = Resources.weekdays

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
        label.textColor = Resources.weekDayColor
		label.font = UIFont.systemFont(ofSize: TextSizeResources.small)
		return label
	}

	@objc func prevBtnTapped(_ sender: UIButton) {
        self.movingTapComplition(.prevMonth)
	}

	@objc func nextBtnTapped(_ sender: UIButton) {
        self.movingTapComplition(.nextMonth)
	}

    func movingTapComplition(_ event: Event) {
        guard !self.timerValid else { return }

        UIImpactFeedbackGenerator(style: .light).impactOccurred(intensity: Resources.feedbackVal)
        self.eventHandler?(event)

        self.tapTimer = Timer.scheduledTimer(withTimeInterval: Resources.debounce, repeats: false) { [weak self] _ in
            self?.tapTimer?.invalidate()
        }
    }
}
