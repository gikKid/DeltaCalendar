import UIKit

internal protocol DayTimeCellRegistratable {
    func timeSelected(_ data: UpdateSelectingModel)
}

extension DayTimeCellRegistratable where Self: AnyObject {

    typealias DayTimeCellRegistration = UICollectionView.CellRegistration<DayTimeListCollectionViewCell, DayTimeItem>

    func createDayTimeRegistration(colors: Colors) -> DayTimeCellRegistration {
        DayTimeCellRegistration { [unowned self] (cell, _, item) in

            cell.selectHandler = { updateData in
                self.timeSelected(updateData)
            }

            cell.configure(with: item.data, colors: colors)
        }
    }
}
