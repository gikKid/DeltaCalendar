# DeltaCalendar
Custom configuring calendar.

<img src="https://github.com/gikKid/DeltaCalendar/blob/main/ContentResource/CalendarView.jpeg" title="" width="550" height="650"/>&nbsp;

## Opportunities
1. Showing years range.
2. Configuring time range at day and minutes offset.
3. Disabling off-time days.
4. Setting custom colors.

## Adding
Use **SPM** to add calendar package at project. ([link](https://github.com/gikKid/DeltaCalendar))

## Using
```swift
let view = DeltaCalendarView(...)
// Return date format is yyyy-MM-dd HH:mm:ssZ
view.delegate = self
```

```swift
// Parameter "from" must be equal or less than parameter "to", otherwise it woudnt be build.
let pickingYearsData = PickingYearModel(from: 2000, to: 2030)
```

```swift
// Weekday must be value from 1 to 7 (gregorian calendar).
// Date format is HH:mm.
// Parameter 'start date' must be less than parameter 'end date'.
let dayTimes: [DayTimeStartModel] =
[
 .init(weekday: 1, startDate: "10:00", endDate: "17:30"),
 .init(weekday: 2, startDate: "09:00", endDate: "18:00")
]

// Parameter offset must be equal or more than '1'.
let showTimeData = ShowTimeModel(data: dayTimes, offset: 15)
```

```swift
let colors = Colors(text: .black, main: .blue, secondaryText: .lightGray, background: .white)
```

## Technologies
1. UIKit
2. Snapkit
3. Calendar(Apple)
4. Combine

## Developing
1. Select year/time in case when scroll is placing between items.
2. Move to next/prev year by horizontal scrolling.