import UIKit

internal protocol MockLoadingRegistrable {}

extension MockLoadingRegistrable {

    typealias CellRegistration = UICollectionView.CellRegistration<MockLoadingCollectionViewCell, MockConfigItem>

    func createMockLoadingCellRegistration() -> CellRegistration {
        CellRegistration { (cell, _, item) in
            cell.configure(with: item.data)
        }
    }
}
