import Foundation

internal struct DayItem: Identifiable {
    let data: Day
    var isDisabled: Bool
    var isSelected: Bool
    let id: ItemID = UUID().uuidString
}

internal struct Day {
    let title: String
    let description: String
    let weekday: Int
    let date: Date?
    let timeData: [DayTime]
}
