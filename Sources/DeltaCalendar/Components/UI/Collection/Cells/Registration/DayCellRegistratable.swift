import UIKit

internal protocol DayCellRegistratable {}

extension DayCellRegistratable {

    typealias DayCellRegistration = UICollectionView.CellRegistration<DayCollectionViewCell, DayItem>

    func createDayCellRegistration(_ colors: Colors) -> DayCellRegistration {
        DayCellRegistration { (cell, _, item) in
            cell.configure(with: item, colors: colors)
        }
    }
}
