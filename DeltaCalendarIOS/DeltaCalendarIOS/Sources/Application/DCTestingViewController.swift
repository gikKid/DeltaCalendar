import UIKit
import SnapKit

final class DCTestingViewController: UIViewController {

	private let contentView: DeltaCalendarView = {
		let pickingYearsData = PickingYearModel(from: 1970, to: 2023)
		let view = DeltaCalendarView(weekendsOff: true, pastDaysOff: false,
									 theme: .light, pickingYearData: pickingYearsData)
		return view
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .lightGray
		self.view.addSubview(self.contentView)

		self.contentView.snp.makeConstraints {
			$0.center.equalTo(self.view)
			$0.height.equalTo(self.view.frame.height / 1.5)
			$0.leading.trailing.equalTo(self.view).inset(SpaceResources.mid)
		}
	}
}
