import Foundation

internal struct ValueItem: Identifiable {
	let value: CustomStringConvertible
	let isMock: Bool
	var isSelected: Bool
	let id: ItemID

	static func buildNoData(text: String) -> Self {
		.init(value: text, isMock: false, isSelected: false, id: UUID().uuidString)
	}
}
