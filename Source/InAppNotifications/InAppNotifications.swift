
import UIKit

public protocol InAppNotificationType {
    var textColor: UIColor { get }
    var backgroundColor: UIColor { get }
    var image: UIImage? { get }
}

public class InAppNotifications {
    
    // MARK: - Static notification types
    
    public static let success: InAppNotificationType = InAppNotificationTypeDefinition(textColor: UIColor.white, backgroundColor: UIColor.flatGreen, image: UIImage(named: "success", in: Bundle(for: InAppNotifications.self), compatibleWith: nil))
    public static let error: InAppNotificationType = InAppNotificationTypeDefinition(textColor: UIColor.white, backgroundColor: UIColor.flatRed, image: UIImage(named: "error", in: Bundle(for: InAppNotifications.self), compatibleWith: nil))
    public static let info: InAppNotificationType = InAppNotificationTypeDefinition(textColor: UIColor.white, backgroundColor: UIColor.flatGray, image: UIImage(named: "info", in: Bundle(for: InAppNotifications.self), compatibleWith: nil))

    
    // MARK: - Init
    
    public init(){}
    
    
    // MARK: - Helpers
    
    /** Shows a CRNotification **/
    public static func showNotification(textColor: UIColor, backgroundColor: UIColor, image: UIImage?, title: String, message: String?, dismissDelay: TimeInterval, completion: @escaping () -> () = {}) {
        let notificationDefinition = InAppNotificationTypeDefinition(textColor: textColor, backgroundColor: backgroundColor, image: image)
        showNotification(type: notificationDefinition, title: title, message: message, dismissDelay: dismissDelay, completion: completion)
    }
    
    /** Shows a CRNotification from a InAppNotificationType **/
    public static func showNotification(type: InAppNotificationType, title: String, message: String?, dismissDelay: TimeInterval, completion: @escaping () -> () = {}) {
        let view = InAppNotificationView()
        
        view.setBackgroundColor(color: type.backgroundColor)
        view.setTextColor(color: type.textColor)
        view.setImage(image: type.image)
        view.setTitle(title: title)
        view.setMessage(message: message)
        view.setDismisTimer(delay: dismissDelay)
		view.setCompletionBlock(completion)
        
        guard let window = UIApplication.shared.keyWindow else {
            print("Failed to show CRNotification. No keywindow available.")
            return
        }
        
        window.addSubview(view)
        view.showNotification()
    }
}

private struct InAppNotificationTypeDefinition: InAppNotificationType {
    var textColor: UIColor
    var backgroundColor: UIColor
    var image: UIImage?
}

private extension UIColor {
    
    /// Flat Colors
    static let flatGreen = UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0)
    static let flatRed = UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0)
    static let flatGray = UIColor(red: 149/255, green: 165/255, blue: 166/255, alpha: 1.0)
    
}

@objc(BSWInAppNotificationView)
private class InAppNotificationView: UIView {
    
    private let imageView: UIImageView = {
        let view = UIImageView()
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
        label.numberOfLines = 2
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }()
    
    private var completion: () -> () = {}
    
    
    // MARK: - Init
    
    required internal init?(coder aDecoder:NSCoder) { fatalError("Not implemented.") }
    
    internal init() {
        let deviceWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let widthFactor: CGFloat = 0.85
        let heightFactor: CGFloat = 0.2
        
        let width = deviceWidth * widthFactor
        let height = width * heightFactor
        super.init(frame: CGRect(x: 0, y: -height, width: width, height: height))
        center.x = UIScreen.main.bounds.width/2
        
        setupLayer()
        setupSubviews()
        setupTargets()
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
        
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
        addAutolayoutSubview(contentStackView)
        contentStackView.pinToSuperview()
    }
    
    private func setupTargets() {
        NotificationCenter.default.addObserver(self, selector: #selector(didRotate), name: UIDevice.orientationDidChangeNotification, object: nil)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissNotification))
        let swipeRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissNotification))
        swipeRecognizer.direction = .up
        
        addGestureRecognizer(tapRecognizer)
        addGestureRecognizer(swipeRecognizer)
    }
    
    
    // MARK: - Helpers
    
    @objc internal func didRotate() {
        UIView.animate(withDuration: 0.2) {
            self.center.x = UIScreen.main.bounds.width / 2
            self.center.y = self.topInset() + 10 + self.frame.height / 2
        }
    }
    
    /** Sets the background color of the notification **/
    internal func setBackgroundColor(color: UIColor) {
        backgroundColor = color
    }
    
    /** Sets the background color of the notification **/
    internal func setTextColor(color: UIColor) {
        titleLabel.textColor = color
        messageLabel.textColor = color
    }
    
    /** Sets the title of the notification **/
    internal func setTitle(title: String) {
        titleLabel.text = title
    }
    
    /** Sets the message of the notification **/
    internal func setMessage(message: String?) {
        messageLabel.text = message
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
            Timer.scheduledTimer(timeInterval: Double(delay), target: self, selector: #selector(dismissNotification), userInfo: nil, repeats: false)
        }
    }
    
    /** Animates in the notification **/
    internal func showNotification() {
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.68, initialSpringVelocity: 0.1, options: UIView.AnimationOptions(), animations: {
            self.frame.origin.y = self.topInset() + 10
        })
    }
    
    /** Animates out the notification **/
    @objc internal func dismissNotification() {
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
