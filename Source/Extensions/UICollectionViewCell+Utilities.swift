import UIKit
import ObjectiveC
import BSWFoundation

public extension UICollectionViewCell {

    private enum Constants {
        static let DeleteButtonTag = 876
        static let Spacing: CGFloat = 7
    }

    fileprivate struct AssociatedBlockHost {
        static var imageHost = "imageHost"
        static var handlerHost = "handlerHost"
    }

    @objc var deleteButtonImage: UIImage? {
        get {
            guard let image = objc_getAssociatedObject(self, &AssociatedBlockHost.imageHost) as? UIImage else { return nil }
            return image
        } set {
            objc_setAssociatedObject(self, &AssociatedBlockHost.imageHost, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc var onDelete: VoidHandler? {
        get {
            guard let handler = objc_getAssociatedObject(self, &AssociatedBlockHost.handlerHost) as? VoidHandler else { return nil }
            return handler
        } set {
            objc_setAssociatedObject(self, &AssociatedBlockHost.handlerHost, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }

    @objc var isDeleting: Bool {
        get {
            return contentView.viewWithTag(Constants.DeleteButtonTag) != nil
        } set {
            if newValue {
                startWiggling()
                let buttonImage = self.deleteButtonImage ?? UIImage.templateImage(.cancelRound)
                let removeButton = UIButton(type: .custom)
                removeButton.tag = Constants.DeleteButtonTag
                removeButton.addTarget(self, action: #selector(onDeleteButtonPressed), for: .touchDown)
                removeButton.setImage(buttonImage, for: .normal)
                contentView.addAutolayoutSubview(removeButton)
                NSLayoutConstraint.activate([
                    removeButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.Spacing),
                    removeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.Spacing)
                    ])
            } else {
                stopWiggling()
                contentView.viewWithTag(Constants.DeleteButtonTag)?.removeFromSuperview()
            }
        }
    }

    func startWiggling() {
        guard contentView.layer.animation(forKey: "wiggle") == nil else { return }
        guard contentView.layer.animation(forKey: "bounce") == nil else { return }

        let angle = 0.04

        let wiggle = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        wiggle.values = [-angle, angle]

        wiggle.autoreverses = true
        wiggle.duration = randomInterval(0.1, variance: 0.005)
        wiggle.repeatCount = Float.infinity

        contentView.layer.add(wiggle, forKey: "wiggle")

        let bounce = CAKeyframeAnimation(keyPath: "transform.translation.y")
        bounce.values = [0.5, 0.0]

        bounce.autoreverses = true
        bounce.duration = randomInterval(0.12, variance: 0.025)
        bounce.repeatCount = Float.infinity

        contentView.layer.add(bounce, forKey: "bounce")
    }

    func stopWiggling() {
        contentView.layer.removeAllAnimations()
    }

    @objc func onDeleteButtonPressed() {
        self.onDelete?()
    }

    private func randomInterval(_ interval: TimeInterval, variance: Double) -> TimeInterval {
        return interval + variance * Double((Double(arc4random_uniform(1000)) - 500.0) / 500.0)
    }
}
