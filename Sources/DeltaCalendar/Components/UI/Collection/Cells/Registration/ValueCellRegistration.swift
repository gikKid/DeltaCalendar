import UIKit

internal protocol ValueCellRegistratable {}

extension ValueCellRegistratable {

    typealias ValueCellRegistration = UICollectionView.CellRegistration<ValueCollectionViewCell, ValueItem>

    func createValueCellRegistration(colors: Colors) -> ValueCellRegistration {
        ValueCellRegistration { (cell, _, item) in
            let text = item.isMock ? "" : item.value

            cell.configure(text: text, isSelected: item.isSelected, colors: colors)
        }
    }
}
