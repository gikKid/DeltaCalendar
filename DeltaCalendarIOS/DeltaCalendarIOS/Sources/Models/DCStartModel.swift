struct DCStartModel {
	let theme: DeltaCalendarTheme
	var isWeekendsDisabled: Bool
	let isPastDaysDisabled: Bool
	let isShowTime: Bool
	let isPickingYear: Bool
}

enum DeltaCalendarTheme {
	case light, dark
}
