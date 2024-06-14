import UIKit

internal struct DayColors {
	
	let centerText: UIColor
	let btmText: UIColor
	let centerTextSelected: UIColor
	let selectedBack: UIColor
	let selectedBtmText: UIColor

	init(theme: Theme) {
		self.centerText = theme == .dark ? ColorsResources.textLightColor! :
		ColorsResources.textDarkColor!

		self.btmText = ColorsResources.dayDescriptColor!

		self.selectedBack = theme == .dark ? ColorsResources.selectedLightColor! :
		ColorsResources.selectedDarkColor!

		self.centerTextSelected = theme == .dark ? ColorsResources.textDarkColor! :
		ColorsResources.textLightColor!

		self.selectedBtmText = self.centerTextSelected
	}
}
