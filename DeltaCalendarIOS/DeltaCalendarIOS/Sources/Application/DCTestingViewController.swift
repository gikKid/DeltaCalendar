import UIKit
import SnapKit

final class DCTestingViewController: UIViewController {

	let contentView = DeltaCalendarView(theme: .light, isShowTime: false, isWeekendsDisabled: false)

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
