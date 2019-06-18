//
//  Created by Pierluigi Cifani on 10/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit
import SafariServices

extension UIViewController {

    // MARK: - Presenting Alerts
    @objc(bsw_showAlertWithMessage:)
    public func showAlert(_ message: String) {
        let operation = PresentAlertOperation(title: nil, message: message, presentingViewController: self)
        alertQueue.addOperation(operation)
    }
    
    @objc(bsw_showErrorAlert:error:)
    public func showErrorAlert(_ message: String, error: Error) {
        
        let errorMessage: String = {
            #if DEBUG
            if let localizedError = error as? LocalizedError, let description = localizedError.errorDescription {
                return "\(message): \(description) \n\n Error code: \(error)"
            } else {
                return "\(message) \n\n Error code: \(error.localizedDescription)"
            }
            #else
            return message
            #endif
        }()
        
        let operation = PresentAlertOperation(title: "error".localized, message: errorMessage, presentingViewController: self)
        alertQueue.addOperation(operation)
    }
    
    @objc(bsw_showTodoMessage)
    public func showTodoAlert() {
        let operation = PresentAlertOperation(title: "To-Do", message: nil, presentingViewController: self)
        alertQueue.addOperation(operation)
    }    
}

//MARK: - Dismissing

extension UIViewController {
    
    //Based on https://stackoverflow.com/a/28158013/1152289
    @objc public func closeViewController(sender: Any?) {
        guard let presentingVC = targetViewController(forAction: #selector(closeViewController(sender:)), sender: sender) else { return }
        presentingVC.closeViewController(sender: sender)
    }
}

extension UINavigationController {
    @objc override public func closeViewController(sender: Any?) {
        self.popViewController(animated: true)
    }
}

//MARK: - SafariViewController
extension UIViewController {
    @objc public func presentSafariVC(withURL url: URL) {
        let safariVC = SFSafariViewController(url: url)
        self.present(safariVC, animated: true, completion: nil)
    }
}

//MARK: - Child VC

extension UIViewController {
    
    public func containViewController(_ vc: UIViewController) {
        addChild(vc)
        view.addAutolayoutSubview(vc.view)
        vc.view.pinToSuperview()
        vc.willMove(toParent: self)
    }
    
    public func removeContainedViewController(_ vc: UIViewController) {
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
    }
    
}

// MARK: Private

private let alertQueue: OperationQueue = {
    let operationQueue = OperationQueue()
    operationQueue.qualityOfService = .userInteractive
    operationQueue.maxConcurrentOperationCount = 1
    operationQueue.name = "com.bswinterfacekit.alertpresenting"
    return operationQueue
}()
