import UIKit
import SnapKit

final class DCTestingViewController: UIViewController {

	private let contentView: DeltaCalendarView = {
		let view = DeltaCalendarView()
		view.disableWeekends(isDisable: true)
		view.disablePastDays(isDisable: true)
		return view
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .lightGray
		self.view.addSubview(self.contentView)

		self.contentView.snp.makeConstraints {
			$0.center.equalTo(self.view)
			$0.height.equalTo(self.view.frame.height / 2)
			$0.leading.trailing.equalTo(self.view).inset(DCSpaceResources.mid)
		}
	}
}
