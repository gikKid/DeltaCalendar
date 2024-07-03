import UIKit
import SnapKit
import DeltaCalendar

final class DCTestingViewController: UIViewController {

	private let contentView: DeltaCalendarView = {
		let pickingYearsData = PickingYearModel(from: 2024, to: 2030)

		let dayTimes: [DayTimeStartModel] =
		[
		 .init(weekday: 1, startDate: "10:00", endDate: "17:30"),
		 .init(weekday: 2, startDate: "09:00", endDate: "18:00"),
         .init(weekday: 3, startDate: "09:00", endDate: "18:00")
		]

		let showTimeData = ShowTimeModel(data: dayTimes, offset: 15)

        let colors = Colors(text: .black, main: .blue, secondaryText: .lightGray, background: .white)

		let view = DeltaCalendarView(pickingYearData: pickingYearsData, showTimeData: showTimeData, colors: colors)
		return view
	}()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.contentView.delegate = self

		self.view.backgroundColor = .lightGray
		self.view.addSubview(self.contentView)

		self.contentView.snp.makeConstraints {
			$0.center.equalTo(self.view)
            $0.height.equalTo(self.view.frame.height / 1.8)
			$0.leading.trailing.equalTo(self.view).inset(10.0)
		}
	}
}

extension DCTestingViewController: DeltaCalendarViewDelegate {
	func dateSelected(_ date: Date) {
		NSLog("\nDate selected: \(date.description)")
	}
}
