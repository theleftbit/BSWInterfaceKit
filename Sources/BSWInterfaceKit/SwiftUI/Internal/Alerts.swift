
#if canImport(UIKit.UIViewController)

import UIKit

enum SwiftUIAlerts {
    @MainActor
    static func presentAlert(title: String, message: String?, cancelButtonTitle: String = "dismiss".localized, confirmButtonTitle: String, isConfirmButtonDestructive: Bool) async -> Bool {
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let rootVC = windowScene.keyWindow?.visibleViewController else { return false }

        var cont: CheckedContinuation<Bool, Never>?
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction({
            UIAlertAction(title: confirmButtonTitle, style: isConfirmButtonDestructive ? .destructive : .default) { _ in
                cont?.resume(returning: true)
            }
        }())
        alertVC.addAction({
            UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
                cont?.resume(returning: false)
            }
        }())
        await rootVC.present(alertVC, animated: true)
        return await withCheckedContinuation { ___cont in
            cont = ___cont
        }
    }
}

#endif
