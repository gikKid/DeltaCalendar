import UIKit

internal final class ShimmerView: UIView, ShimmerLoadable {

    private(set) var gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupShimmer(at: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
