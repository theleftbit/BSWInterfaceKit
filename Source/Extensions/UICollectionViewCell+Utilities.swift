import UIKit
import ObjectiveC
import BSWFoundation

public extension UICollectionViewCell {

    public enum WiggleAppearance {
        public static var DeleteButtonImage: UIImage?
        public static var WiggleDuration: TimeInterval = 0.1
        public static var BounceDuration: TimeInterval = 0.12
    }

    func startWiggling() {
        guard contentView.layer.animation(forKey: "wiggle") == nil else { return }
        guard contentView.layer.animation(forKey: "bounce") == nil else { return }

        let wiggle: CAKeyframeAnimation = {
            let angle: Double = 0.04
            let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
            animation.values = [-angle, angle]
            animation.autoreverses = true
            animation.duration = randomInterval(WiggleAppearance.WiggleDuration, variance: 0.005)
            animation.repeatCount = Float.infinity
            return animation
        }()
        contentView.layer.add(wiggle, forKey: "wiggle")

        let bounce: CAKeyframeAnimation = {
            let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
            animation.values = [0.5, 0.0]
            animation.autoreverses = true
            animation.duration = randomInterval(WiggleAppearance.BounceDuration, variance: 0.025)
            animation.repeatCount = Float.infinity
            return animation
        }()
        contentView.layer.add(bounce, forKey: "bounce")
    }

    func stopWiggling() {
        contentView.layer.removeAllAnimations()
    }
}

private func randomInterval(_ interval: TimeInterval, variance: Double) -> TimeInterval {
    return interval + variance * Double((Double(arc4random_uniform(1000)) - 500.0) / 500.0)
}
