import UIKit

internal final class MockLoadingCollectionViewCell: UICollectionViewCell {

    private let contentStackView: UIStackView = {
        $0.axis = .horizontal
        $0.spacing = SpaceResources.mid
        $0.distribution = .fillEqually
        $0.alignment = .leading
        return $0
    }(UIStackView())

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentView.addSubview(self.contentStackView)

        self.contentStackView.snp.makeConstraints {
            $0.edges.equalTo(self.contentView)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with days: [DayItem]) {
        let height = HeightResources.text
        let frame = CGRect(x: 0, y: 0, width: height * 2, height: height)

        (0..<days.count).forEach { index in
            let shimmerView = ShimmerView(frame: frame)

            self.contentStackView.addArrangedSubview(shimmerView)
        }
    }
}
