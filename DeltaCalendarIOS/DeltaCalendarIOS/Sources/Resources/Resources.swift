import Foundation

internal enum Resources {
	static let maxYear: Int = 2030
	static let weekends: [Int] = [7, 1] /// at gregorian a week starts from sunday
	static let mondayIndex: Int = 2
	static let weekdays: [String] = [TextResources.mon, TextResources.tue,
									 TextResources.wed, TextResources.thu,
									 TextResources.fri, TextResources.sat,
									 TextResources.sun]
	static let monthCount: Int = 12
	static let feedbackVal: CGFloat = 0.5
}