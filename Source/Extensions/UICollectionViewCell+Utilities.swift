import UIKit
import ObjectiveC
import BSWFoundation

public extension UICollectionViewCell {

    enum WiggleAppearance {
        public static var Spacing: CGFloat = 7
        public static var DeleteButtonImage: UIImage?
        public static var WiggleDuration: TimeInterval = 0.1
        public static var BounceDuration: TimeInterval = 0.12

        fileprivate static let DeleteButtonTag = 876
    }

    private enum AssociatedBlockHost {
        static var handlerHost = "handlerHost"
    }

    @objc var bsw_onDelete: VoidHandler? {
        get {
            guard let handler = objc_getAssociatedObject(self, &AssociatedBlockHost.handlerHost) as? VoidHandler else { return nil }
            return handler
        } set {
            objc_setAssociatedObject(self, &AssociatedBlockHost.handlerHost, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc var bsw_isDeleting: Bool {
        get {
            return contentView.viewWithTag(WiggleAppearance.DeleteButtonTag) != nil
        } set {
            if newValue {
                startWiggling()
                let buttonImage = WiggleAppearance.DeleteButtonImage ?? UIImage.templateImage(.cancelRound)
                let removeButton = UIButton(type: .custom)
                removeButton.tag = WiggleAppearance.DeleteButtonTag
                removeButton.addTarget(self, action: #selector(onDeleteButtonPressed), for: .touchDown)
                removeButton.setImage(buttonImage, for: .normal)
                contentView.addAutolayoutSubview(removeButton)
                NSLayoutConstraint.activate([
                    removeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: WiggleAppearance.Spacing),
                    removeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: WiggleAppearance.Spacing)
                    ])
            } else {
                stopWiggling()
                contentView.viewWithTag(WiggleAppearance.DeleteButtonTag)?.removeFromSuperview()
            }
        }
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

    @objc func onDeleteButtonPressed() {
        self.bsw_onDelete?()
    }
}

private func randomInterval(_ interval: TimeInterval, variance: Double) -> TimeInterval {
    return interval + variance * Double((Double(arc4random_uniform(1000)) - 500.0) / 500.0)
}
