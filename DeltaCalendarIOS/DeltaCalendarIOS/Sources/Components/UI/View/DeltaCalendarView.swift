import UIKit

final class DeltaCalendarView: UIView {
	
	private var theme: Theme = .light

	enum Theme {
		case light, dark
	}

	convenience init(theme: Theme) {
		self.init(frame: .zero)
		self.theme = theme
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupView()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private extension DeltaCalendarView {
	func setupView() {
		self.backgroundColor = theme == .dark ? UIColor(named: ColorsResources.darkBackColor)
		: UIColor(named: ColorsResources.lightBackColor)
	}
}
