import Foundation

internal enum CalendarError: Error, CustomStringConvertible {

    case selectingYear, fromToYears, timeOffset, startEndTime, dataConfiguring
    case weekday(Int)
    case timeFormat(String)

    var description: String {
        
        var text = "[ERROR]: "

        switch self {
        case .selectingYear:
            text.append("Year was not selected.")
        case .fromToYears:
            text.append("'From' year must be equal or less than 'to' year.")
        case .timeOffset:
            text.append("Time offset must be equal or more than 1.")
        case .weekday(let val):
            text.append("Weekday is not correct. It must be value between 1 and 7 (\(val)")
        case .timeFormat(let format):
            text.append("Time format is '\(format)'")
        case .startEndTime:
            text.append("'Start date' parameter must be less than 'end date' parameter at time in day")
        case .dataConfiguring:
            text.append("There arent year at data in view model.")
        }

        return text
    }
}
