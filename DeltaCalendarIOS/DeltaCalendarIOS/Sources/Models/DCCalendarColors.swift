import UIKit

struct DCalendarDayColors {
	
	let centerText: UIColor
	let btmText: UIColor
	let centerTextSelected: UIColor
	let selectedBack: UIColor
	let selectedBtmText: UIColor

	init(theme: DeltaCalendarTheme) {
		self.centerText = theme == .dark ? DCColorsResources.textLightColor! :
		DCColorsResources.textDarkColor!

		self.btmText = DCColorsResources.dayDescriptColor!

		self.selectedBack = theme == .dark ? DCColorsResources.selectedLightColor! :
		DCColorsResources.selectedDarkColor!

		self.centerTextSelected = theme == .dark ? DCColorsResources.textDarkColor! :
		DCColorsResources.textLightColor!

		self.selectedBtmText = self.centerTextSelected
	}
}
