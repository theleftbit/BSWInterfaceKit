
import UIKit

public enum TextFieldAlertController {

    public static func controllerWith(title: String, subtitle: String? = nil, actionTitle: String, cancelTitle: String, placeholder: String? = nil, initialValue: String? = nil, onAction: @escaping (String?) -> (), onCancelAction: (() -> ())? = nil) -> UIViewController {
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
            observation = NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: $0, queue: OperationQueue.main) { [weak action] (note) in
                guard let t = note.object as? UITextField else { return }
                textField = t
                action?.isEnabled = (t.text?.count ?? 0) > 0
            }
        }

        return alertVC
    }
}
