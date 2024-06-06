# DeltaCalendar
Custom configuring calendar.

## Opportunities
1. Disabling specific days.
2. Configuring time range at day and minutes offset.
3. Show/hide picking years and time.
4. Dark/light theme.

## Using
```swift
let view = DeltaCalendarView()
view.delegate = self

let pickingYearsData = PickingYearModel(from: 1970, to: 2023) // from parameter must be less than "to" parameter, otherwise it woudnt be build.
```
