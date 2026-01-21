#if canImport(UIKit.UIViewController)

import UIKit

/// Describes the type of notification shown.
public protocol InAppNotificationType {
    /// The background color for the notification
    var backgroundColor: UIColor { get }
    /// An optional image (please use an icon)
    var image: UIImage? { get }
}

@MainActor
public enum InAppNotifications {
    
    // MARK: - Helpers
    
    /// Creates an in-app notification, to let the user know that something has happened
    /// - Parameters:
    ///   - fromVC: What `viewController` this will be presented on.
    ///   - backgroundColor: The background color for the notification.
    ///   - image: An optional image (please use an icon)
    ///   - title: A title.
    ///   - message: An optional message.
    ///   - dismissDelay: How long before it'll be dismissed
    ///   - completion: A completion handler when the notification is dismissed.
    /// - Returns: The notification.
    public static func showNotification(fromVC: UIViewController, backgroundColor: UIColor, image: UIImage?, title: NSAttributedString, message: NSAttributedString?, dismissDelay: TimeInterval, completion: @escaping () -> () = {}) {
        let notificationDefinition = InAppNotificationTypeDefinition(backgroundColor: backgroundColor, image: image)
        showNotification(type: notificationDefinition, fromVC: fromVC, title: title, message: message, dismissDelay: dismissDelay, completion: completion)
    }
    
    /// Creates an in-app notification, to let the user know that something has happened
    /// - Parameters:
    ///   - type: The type of notification shown
    ///   - fromVC: What `viewController` this will be presented on.
    ///   - title: A title.
    ///   - message: An optional message.
    ///   - dismissDelay: How long before it'll be dismissed
    ///   - completion: A completion handler when the notification is dismissed.
    /// - Returns: The notification.
    public static func showNotification(type: InAppNotificationType, fromVC: UIViewController, title: NSAttributedString?, message: NSAttributedString?, dismissDelay: TimeInterval, completion: @escaping () -> () = {}) {
        let view = InAppNotificationView()
        
        view.setBackgroundColor(color: type.backgroundColor)
        view.setImage(image: type.image)
        view.setTitle(title: title)
        view.setMessage(message: message)
        view.setDismisTimer(delay: dismissDelay)
        view.setCompletionBlock(completion)
        view.prepareFrame(fromVC: fromVC)
        
        guard let window = fromVC.view.window else {
            print("Failed to show CRNotification. No keywindow available.")
            return
        }
        
        window.addSubview(view)
        view.showNotification()
    }
}

private struct InAppNotificationTypeDefinition: InAppNotificationType {
    var backgroundColor: UIColor
    var image: UIImage?
}

@objc(BSWInAppNotificationView)
private class InAppNotificationView: UIView {
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .white
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.bold)
        label.textColor = .white
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.semibold)
        label.textColor = .white
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()
    
    private var completion: () -> () = {}
    
    
    // MARK: - Init
    
    required internal init?(coder aDecoder:NSCoder) { fatalError("Not implemented.") }
    
    internal init() {
        super.init(frame: .zero)
        setupLayer()
        setupSubviews()
        setupTargets()
    }
    
    func prepareFrame(fromVC: UIViewController) {
        let bounds = fromVC.view.window?.bounds ?? UIScreen.main.bounds
        let deviceWidth = min(bounds.width, bounds.height)
        let widthFactor: CGFloat = (fromVC.view.window?.traitCollection.horizontalSizeClass == .compact) ? 0.85 : 0.5
        let width = deviceWidth * widthFactor
        let height: CGFloat = {
            let size = systemLayoutSizeFitting(
                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            return size.height
        }()
        self.frame = CGRect(x: 0, y: -height, width: width, height: height)
        self.center.x = bounds.width/2
    }
    
    // MARK: - Setup
    
    private func setupLayer() {
        layer.cornerRadius = 5
        layer.shadowRadius = 5
        layer.shadowOpacity = 0.25
        layer.shadowColor = UIColor.lightGray.cgColor
    }
    
    private func setupSubviews() {
        let textStackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        textStackView.axis = .vertical
        textStackView.spacing = 3
        textStackView.alignment = .center
        
        let contentStackView = UIStackView(arrangedSubviews: [imageView, textStackView])
        contentStackView.axis = .horizontal
        contentStackView.spacing = 8
        contentStackView.layoutMargins = .init(uniform: 12)
        contentStackView.isLayoutMarginsRelativeArrangement = true
        
        addAutolayoutSubview(contentStackView)
        contentStackView.pinToSuperview()
    }
    
    private func setupTargets() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(didRotate), name: UIDevice.orientationDidChangeNotification, object: nil)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(_dismissNotification))
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(_dismissNotification))
        swipeRecognizer.direction = .up
        
        addGestureRecognizer(tapRecognizer)
        addGestureRecognizer(swipeRecognizer)
    }
    
    
    // MARK: - Helpers
    
    @objc internal func didRotate() {
        UIView.animate(withDuration: 0.2) {
            let bounds = self.window?.bounds ?? UIScreen.main.bounds
            self.center.x = bounds.width / 2
            self.center.y = self.topInset() + 10 + self.frame.height / 2
        }
    }
    
    /** Sets the background color of the notification **/
    internal func setBackgroundColor(color: UIColor) {
        backgroundColor = color
    }
    
    /** Sets the title of the notification **/
    internal func setTitle(title: NSAttributedString?) {
        titleLabel.attributedText = title
        titleLabel.isHidden = (title == nil)
    }
    
    /** Sets the message of the notification **/
    internal func setMessage(message: NSAttributedString?) {
        messageLabel.attributedText = message
        messageLabel.isHidden = (message == nil)
    }
    
    /** Sets the image of the notification **/
    internal func setImage(image: UIImage?) {
        imageView.image = image
        imageView.isHidden = (image == nil)
    }
    
    /** Sets the completion block of the notification for when it is dismissed **/
    internal func setCompletionBlock(_ completion: @escaping () -> ()) {
        self.completion = completion
    }
    
    /** Dismisses the notification with a delay > 0 **/
    internal func setDismisTimer(delay: TimeInterval) {
        if delay > 0 {
            Timer.scheduledTimer(timeInterval: Double(delay), target: self, selector: #selector(_dismissNotification), userInfo: nil, repeats: false)
        }
    }
    
    /** Animates in the notification **/
    internal func showNotification() {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.68, initialSpringVelocity: 0.1, options: UIView.AnimationOptions(), animations: {
            self.frame.origin.y = self.topInset() + 10
        })
    }
    
    /** Animates out the notification **/
    @objc private func _dismissNotification() {
        dismissNotification(animated: true)
    }
    
    func dismissNotification(animated: Bool) {
        guard animated else {
            removeFromSuperview()
            return
        }
        UIView.animate(withDuration: 0.1, animations: {
            self.frame.origin.y = self.frame.origin.y + 5
        }, completion: {
            (complete: Bool) in
            UIView.animate(withDuration: 0.25, animations: {
                self.center.y = -self.frame.height
            }, completion: { [weak self] (complete) in
                self?.completion()
                self?.removeFromSuperview()
            })
        })
    }
    
    private func topInset() -> CGFloat {
        return self.safeAreaInsets.top
    }
}
#endif
