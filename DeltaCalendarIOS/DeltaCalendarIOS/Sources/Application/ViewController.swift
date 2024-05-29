import UIKit
import SnapKit

final class ViewController: UIViewController {

	let contentView = DeltaCalendarView(theme: .light)

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .lightGray
		self.view.addSubview(self.contentView)

		self.contentView.snp.makeConstraints {
			$0.center.equalTo(self.view)
			$0.height.equalTo(self.view.frame.height / 2)
			$0.width.equalTo(self.view.frame.width / 1.25)
		}
	}
}
