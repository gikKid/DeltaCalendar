import Foundation

internal struct MockConfigItem: Identifiable {
    let data: [DayItem]
    let id: String = UUID().uuidString
}
