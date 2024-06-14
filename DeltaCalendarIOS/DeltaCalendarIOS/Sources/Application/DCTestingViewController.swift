import UIKit
import SnapKit

final class DCTestingViewController: UIViewController {

	private let contentView: DeltaCalendarView = {
		let pickingYearsData = PickingYearModel(from: 2020, to: 2024)

		let dayTimes: [DayTimeStartModel] =
		[.init(weekday: 1, startDate: "10:00", endDate: "17:30"),
		 .init(weekday: 2, startDate: "09:00", endDate: "18:00")
		]

		let showTimeData = ShowTimeModel(data: dayTimes, offset: 15)

		let view = DeltaCalendarView(weekendsOff: false, pastDaysOff: false,
									 theme: .light, pickingYearData: pickingYearsData,
									 showTimeData: showTimeData)
		return view
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.contentView.delegate = self

		self.view.backgroundColor = .lightGray
		self.view.addSubview(self.contentView)

		self.contentView.snp.makeConstraints {
			$0.center.equalTo(self.view)
			$0.height.equalTo(self.view.frame.height / 1.75)
			$0.leading.trailing.equalTo(self.view).inset(SpaceResources.mid)
		}
	}
}

extension DCTestingViewController: DeltaCalendarViewDelegate {
	func dateSelected(_ date: Date) {
		NSLog("\nDate selected: \(date.description)")
	}
}
