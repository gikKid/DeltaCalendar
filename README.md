# DeltaCalendar
Custom configuring calendar.

<img src="https://github.com/gikKid/DeltaCalendar/blob/main/ContentResource/IMG_5318.jpg" title="Picking year, configue custom days with time and offset by 15 min" width="600" height="600"/>&nbsp;
<img src="https://github.com/gikKid/DeltaCalendar/blob/main/ContentResource/IMG_5319.jpg" title="Default view with disabled weekends" width="500" height="500"/>&nbsp;
<img src="https://github.com/gikKid/DeltaCalendar/blob/main/ContentResource/IMG_5320.jpg" title="Dark theme" width="500" height="500"/>&nbsp;

## Opportunities
1. Disabling wekeends and past days. Off-time days also would be disabled.
2. Configuring time range at day and minutes offset.
3. Show/hide picking years and time.
4. Dark/light theme.

## Using
```swift
let view = DeltaCalendarView()
view.delegate = self
``` 

```swift
// Parameter "from" must be equal or less than parameter "to", otherwise it woudnt be build.
let pickingYearsData = PickingYearModel(from: 1970, to: 2023)
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

## Technologies
1. UIKit
2. Snapkit
3. Calendar(Apple)
4. Combine
