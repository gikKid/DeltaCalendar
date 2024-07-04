import UIKit

internal protocol ShimmerLoadable {
    var gradientLayer: CAGradientLayer { get }
}

extension ShimmerLoadable {

    func setupShimmer(at view: UIView) {
        self.gradientLayer.startPoint = .init(x: 0.0, y: 0.5)
        self.gradientLayer.endPoint = .init(x: 1.0, y: 0.5)
        self.gradientLayer.cornerRadius = view.bounds.height / 2
        self.gradientLayer.frame = view.bounds

        let animation = self.makeAnimationGroup()
        self.gradientLayer.add(animation, forKey: "backgroundColor")

        view.layer.addSublayer(self.gradientLayer)
    }

    func updateShimmer(isShow: Bool) {
        self.gradientLayer.isHidden = !isShow
    }

    private func makeAnimationGroup(previousGroup: CAAnimationGroup? = nil) -> CAAnimationGroup {
        let animDuration: CFTimeInterval = 1.5

        let anim1 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
        anim1.fromValue = UIColor.gradientLightGrey.cgColor
        anim1.toValue = UIColor.gradientDarkGrey.cgColor
        anim1.duration = animDuration
        anim1.beginTime = 0.0

        let anim2 = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.backgroundColor))
        anim2.fromValue = UIColor.gradientDarkGrey.cgColor
        anim2.toValue = UIColor.gradientLightGrey.cgColor
        anim2.duration = animDuration
        anim2.beginTime = anim1.beginTime + anim1.duration

        let group = CAAnimationGroup()
        group.beginTime = 0.0
        group.animations = [anim1, anim2]
        group.repeatCount = .greatestFiniteMagnitude
        group.duration = anim2.beginTime + anim2.duration
        group.isRemovedOnCompletion = false

        if let previousGroup = previousGroup {
            // Offset groups by seconds for effect
            group.beginTime = previousGroup.beginTime + Resources.shimmerOffset
        }

        return group
    }
}
