# DeltaCalendar
Custom configuring calendar.

## Opportunities
1. Disabling wekeends and past days.
2. Configuring time range at day and minutes offset.
3. Show/hide picking years and time.
4. Dark/light theme.

## Using
```swift
let view = DeltaCalendarView()
view.delegate = self

let pickingYearsData = PickingYearModel(from: 1970, to: 2023) // parameter "from" must be less than parameter "to", otherwise it woudnt be build.
```

## Technologies
1. UIKit
2. Snapkit
3. Calendar(Apple)
4. Combine
