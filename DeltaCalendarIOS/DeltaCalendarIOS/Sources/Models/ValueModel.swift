import Foundation

internal struct ValueItem: Identifiable {
	let value: CustomStringConvertible
	let isMock: Bool
	var isSelected: Bool
	let id: ItemID
}
