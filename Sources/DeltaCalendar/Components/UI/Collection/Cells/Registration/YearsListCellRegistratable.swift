import UIKit

internal protocol YearsListCellRegistratable {
    func yearSelected(_ data: UpdateSelectingModel)
}

extension YearsListCellRegistratable where Self: AnyObject {

    typealias YearsListCellRegistration = UICollectionView.CellRegistration<YearsListCollectionViewCell, YearsItem>

    func createYearsCellRegistration(colors: Colors) -> YearsListCellRegistration {
        YearsListCellRegistration { [unowned self] (cell, _, item) in
            cell.selectHandler = { updateData in
                self.yearSelected(updateData)
            }

            cell.configure(with: item.data, colors: colors)
        }
    }
}
