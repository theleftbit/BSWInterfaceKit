//
//  Created by Pierluigi Cifani on 10/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import Foundation

// MARK: - Error and Loading

extension UIViewController {

    // MARK: - Loaders
    @objc(bsw_showLoader)
    public func showLoader() {
        view.subviews.forEach { $0.alpha = 0.0 }
        let spinner = LoadingView()
        spinner.tag = Constants.LoaderTag
        view.addSubview(spinner)
        spinner.centerInSuperview()
    }

    @objc(bsw_hideLoader)
    public func hideLoader() {
        view.findSubviewWithTag(Constants.LoaderTag)?.removeFromSuperview()
        view.subviews.forEach { $0.alpha = 1.0 }
    }


    // MARK: - Alerts

    @objc(bsw_showErrorMessage:error:)
    public func showErrorMessage(_ message: String, error: Error) {

        #if DEBUG
            let errorMessage = "\(message). \(error)"
        #else
            let errorMessage = message
        #endif
        
        let operation = PresentAlertOperation(title: "Error", message: errorMessage, presentingViewController: self)
        errorQueue.addOperation(operation)
    }

    @objc(bsw_showTodoMessage)
    public func showTodoMessage() {
        let operation = PresentAlertOperation(title: "ToDo", message: nil, presentingViewController: self)
        errorQueue.addOperation(operation)
    }

  // MARK: - Bottom Action Button

    @nonobjc
    public func addBottomActionButton(_ buttonConfig: ButtonConfiguration) {
    
        guard traitCollection.horizontalSizeClass == .compact else { fatalError() }
        
        func animateChanges(_ changes: @escaping () -> ()) {

            guard NSClassFromString("XCTest") == nil else {
                changes()
                return
            }

            UIView.animate(
                withDuration: Constants.ButtonAnimationDuration,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: [],
                animations: {
                    changes()
                },
                completion: nil
            )
        }
        
        if let actionButton = view.findSubviewWithTag(Constants.BottomActionTag) as? UIButton {
            animateChanges {
                actionButton.setButtonConfiguration(buttonConfig)
            }
        } else {
            
            removeBottonActionButton()

            let button = UIButton()
            button.tag = Constants.BottomActionTag
            button.setButtonConfiguration(buttonConfig)
            view.addAutolayoutSubview(button)
            
            let bottomConstraint = button.bottomAnchor.constraint(equalTo: view.bottomAnchor)

            NSLayoutConstraint.activate([
                bottomConstraint,
                button.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.ButtonHeight),
                button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])

            view.layoutIfNeeded()

            //Now, let's animate how this is shown
            bottomConstraint.constant = button.bounds.height
            view.layoutIfNeeded()
            bottomConstraint.constant = 0
            animateChanges {
                self.view.layoutIfNeeded()
            }
        }
    }

    @nonobjc
    public func removeBottonActionButton() {
        view.removeSubviewWithTag(Constants.BottomActionTag)
    }
}

extension UIViewController {
    //Based on https://stackoverflow.com/a/28158013/1152289
    @objc public func closeViewController(sender: Any?) {
        guard let presentingVC = targetViewController(forAction: #selector(closeViewController(sender:)), sender: sender) else { return }
        presentingVC.closeViewController(sender: sender)
    }
}

extension UINavigationController {
    @objc
    override public func closeViewController(sender: Any?) {
        self.popViewController(animated: true)
    }
}


// MARK: Private

private enum Constants {
    fileprivate static let BottomActionTag = 345678
    fileprivate static let ButtonAnimationDuration = 0.6
    fileprivate static let ButtonHeight = CGFloat(50)
    fileprivate static let LoaderTag = Int(888)
}

private let errorQueue: OperationQueue = {
  let operationQueue = OperationQueue()
  operationQueue.maxConcurrentOperationCount = 1
  return operationQueue
}()
