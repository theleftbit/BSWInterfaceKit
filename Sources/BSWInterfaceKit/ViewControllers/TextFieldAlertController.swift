#if canImport(UIKit.UITextField)

import UIKit

@MainActor
public enum TextFieldAlertController {
    
    public typealias ActionValidator = @Sendable (String) -> Bool
    
    /// Creates an alert with a `UITextField` to capture user input.
    /// - Parameters:
    ///   - title: The title of the alert
    ///   - subtitle: The subtitle of the alert
    ///   - actionTitle: The title of the action to be performed
    ///   - cancelTitle: The title for cancelling the action to be performed
    ///   - placeholder: The placeholder of the `UITextField`
    ///   - initialValue: The initial value of the `UITextField`
    ///   - textContentType: The `UITextContentType` of the `UITextField`
    ///   - actionValidator: A block that validates the current user's input and enables the Action button.
    ///   - onAction: The handler to be executed when the user presses the Action button
    ///   - onCancelAction: The handler to be executed when the user presses the Cancel button
    /// - Returns: A `UIViewController` to be presented
    public static func controllerWith(
        title: String,
        subtitle: String? = nil,
        actionTitle: String,
        cancelTitle: String,
        placeholder: String? = nil,
        initialValue: String? = nil,
        textContentType: UITextContentType? = nil,
        actionValidator: @escaping ActionValidator = { $0.count > 0 },
        onAction: @escaping (String?) -> (),
        onCancelAction: (() -> ())? = nil) -> UIViewController {
            let alertVC = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
            
            var observation: NSObjectProtocol!
            var textField: UITextField!
            
            let action = UIAlertAction(title: actionTitle, style: .default) { _ in
                onAction(textField.text)
                observation = nil
                textField = nil
            }
            action.isEnabled = false
            alertVC.addAction(action)
            
            let cancel = UIAlertAction(title: cancelTitle, style: .cancel) {  _ in
                onCancelAction?()
                observation = nil
                textField = nil
            }
            alertVC.addAction(cancel)
            
            alertVC.addTextField { [weak action] inputTextField in
                guard observation == nil else { return }
                
                inputTextField.text = initialValue
                inputTextField.placeholder = placeholder
                inputTextField.textContentType = textContentType
                inputTextField.isSecureTextEntry = (textContentType == .password)
                
                observation = NotificationCenter.default.addObserver(
                    forName: UITextField.textDidChangeNotification,
                    object: inputTextField,
                    queue: OperationQueue.main
                ) { note in
                    guard let t = note.object as? UITextField else { return }
                    
                    MainActor.assumeIsolated {
                        textField = t
                        action?.isEnabled = actionValidator(t.text ?? "")
                    }
                }
            }
            
            return alertVC
        }
}

#endif
