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
    
    @nonobjc @discardableResult
    public func addBottomActionButton(buttonConfig: ButtonConfiguration, margin: UIEdgeInsets = .zero) -> UIButton {
        if let actionButton = view.findSubviewWithTag(Constants.BottomActionTag) as? UIButton {
            actionButton.setButtonConfiguration(buttonConfig)
            return actionButton
        } else {
            let button = UIButton(buttonConfiguration: buttonConfig)
            addBottomActionButton(button: button, margin: margin)
            return button
        }
    }
    
    @nonobjc
    public func addBottomActionButton(button: UIButton, margin: UIEdgeInsets = .zero) {

        /*
         TODO: Add with swizzling a way to avoid this code in clients:
         override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            navigationController?.setNavigationBarHidden(false, animated: true)
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tableView.frame.size.height - continueButton.frame.minY, right: 0)
         }
         */
        
        guard traitCollection.horizontalSizeClass == .compact else { fatalError() }
        
        removeBottonActionButton()
        
        view.addAutolayoutSubview(button)
        
        let bottomConstraint: NSLayoutConstraint
        let bottomAnchor: NSLayoutYAxisAnchor

        if margin.bottom == 0 {
            bottomAnchor = self.view.bottomAnchor
        } else {
            if #available(iOS 11.0, *) {
                bottomAnchor = self.view.safeAreaLayoutGuide.bottomAnchor
            } else {
                bottomAnchor = self.bottomLayoutGuide.topAnchor
            }
        }
        
        bottomConstraint = button.bottomAnchor.constraint(equalTo: bottomAnchor)

        NSLayoutConstraint.activate([
            bottomConstraint,
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.ButtonHeight),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin.left),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin.right)
            ])
        
        view.layoutIfNeeded()
        
        //Let's add a content inset if required
        if let scrollView = self.view.subviews.first as? UIScrollView {
            let margin: CGFloat = 20
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: scrollView.frame.size.height - button.frame.minY + margin, right: 0)
        }

        //Now, let's animate how this is shown
        bottomConstraint.constant = button.bounds.height
        view.layoutIfNeeded()
        bottomConstraint.constant = -margin.bottom
        animateChanges {
            self.view.layoutIfNeeded()
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


private func animateChanges(_ changes: @escaping () -> ()) {
    
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
