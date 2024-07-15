import Foundation
import UIKit

internal enum Resources {
    static let weekends: [Int] = [7, 1] /// at gregorian a week starts from sunday
    static let mondayIndex: Int = 2
    static let weekdays: [String] = [TextResources.mon.capitalized, TextResources.tue.capitalized,
                                     TextResources.wed.capitalized, TextResources.thu.capitalized,
                                     TextResources.fri.capitalized, TextResources.sat.capitalized,
                                     TextResources.sun.capitalized]
    static let monthCount: Int = 12
    static let monthHeight: CGFloat = 310.0
    static let feedbackVal: CGFloat = 0.5
    static let selectingYearGap: Int = 18
    static let minValScale: CGFloat = 0.7
    static let maxValScale: CGFloat = 1.1
    static let debounce: TimeInterval = 0.7
    static let shimmerOffset = 0.33
    static let isoFormat: String = "yyyy/MM/dd"
    static let dateFormat: String = "\(Self.isoFormat) \(Self.timeFormat)"
    static let timeFormat: String = "HH:mm"
    static let locale = "en_RU"
    static let weekDayColor: UIColor = .lightGray

    static var today: Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: Date()))

        return Date(timeInterval: seconds, since: Date())
    }
}
