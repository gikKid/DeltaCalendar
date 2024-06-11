# DeltaCalendar
Custom configuring calendar.

## Opportunities
1. Disabling wekeends and past days. Off-time days also would be disabled.
2. Configuring time range at day and minutes offset.
3. Show/hide picking years and time.
4. Dark/light theme.

## Using
```swift
let view = DeltaCalendarView()
view.delegate = self

// Parameter "from" must be equal or less than parameter "to", otherwise it woudnt be build.
let pickingYearsData = PickingYearModel(from: 1970, to: 2023)

// Weekday must be value from 1 to 7 (gregorian calendar).
// Date format is HH:mm.
// Parameter 'start date' must be less than parameter 'end date'.
let dayTimes: [DayTimeModel] =
[.init(weekday: 1, startDate: "10:00", endDate: "17:30"),
 .init(weekday: 2, startDate: "09:00", endDate: "18:00")
]

// Parameter offset must be equal or more than '1'.
let showTimeData = ShowTimeModel(data: dayTimes, offset: 15)
```

## Technologies
1. UIKit
2. Snapkit
3. Calendar(Apple)
4. Combine
