#if canImport(UIKit)

import UIKit

public enum TextFieldAlertController {

    public static func controllerWith(
        title: String,
        subtitle: String? = nil,
        actionTitle: String,
        cancelTitle: String,
        placeholder: String? = nil,
        initialValue: String? = nil,
        textContentType: UITextContentType? = nil,
        actionValidator: @escaping ((String) -> Bool) = { $0.count > 0 },
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
        
        alertVC.addTextField {
            guard observation == nil else { return }
            $0.text = initialValue
            $0.placeholder = placeholder
            $0.textContentType = textContentType
            $0.isSecureTextEntry = (textContentType == .password)
            observation = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: $0, queue: OperationQueue.main) { [weak action] (note) in
                guard let t = note.object as? UITextField else { return }
                textField = t
                action?.isEnabled = actionValidator(t.text ?? "")
            }
        }

        return alertVC
    }
}
#endif
