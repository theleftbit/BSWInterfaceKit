//
//  Created by Pierluigi Cifani on 10/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

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
        let errorMessage = "\(message) \n\n Error code: \(error)"
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
    
    @nonobjc @discardableResult @available(iOS 11.0, *)
    public func addBottomActionButton(buttonConfig: ButtonConfiguration, margin: UIEdgeInsets = .zero) -> UIButton {
        if let buttonContainer = self.buttonContainer {
            buttonContainer.button.setButtonConfiguration(buttonConfig)
            return buttonContainer.button
        } else {
            let button = UIButton(buttonConfiguration: buttonConfig)
            addBottomActionButton(button: button, margin: margin)
            return button
        }
    }
    
    @available(iOS 11.0, *)
    public func addBottomActionButton(button: UIButton, margin: UIEdgeInsets = .zero) {
        
        guard traitCollection.horizontalSizeClass == .compact else { fatalError() }
        
        removeBottonActionButton()
        
        let buttonContainer = ButtonContainerViewController(button: button, margin: margin)
        addChild(buttonContainer)
        view.addAutolayoutSubview(buttonContainer.view)
        
        let bottomConstraint = buttonContainer.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            buttonContainer.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonContainer.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
            ])
        buttonContainer.didMove(toParent: self)
        view.layoutIfNeeded()
    
        additionalSafeAreaInsets = UIEdgeInsets(dictionaryLiteral: (.bottom, buttonContainer.view.frame.height + margin.bottom))
        
        //Now, let's animate how this is shown
        bottomConstraint.constant = buttonContainer.view.bounds.height
        view.layoutIfNeeded()
        bottomConstraint.constant = 0
        animateChanges {
            self.view.layoutIfNeeded()
        }
    }

    @available(iOS 11.0, *)
    public func removeBottonActionButton() {
        guard let buttonContainer = self.buttonContainer else { return }
        buttonContainer.willMove(toParent: nil)
        buttonContainer.view.removeFromSuperview()
        buttonContainer.removeFromParent()
    }
    
    @available(iOS 11.0, *)
    private var buttonContainer: ButtonContainerViewController? {
        return self.children.compactMap({ return $0 as? ButtonContainerViewController }).first
    }
}

// MARK: - Presenting and dismissing

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

@available(iOS 11.0, *) @objc(BSWButtonContainerViewController)
private class ButtonContainerViewController: UIViewController {
    
    let button: UIButton
    let margin: UIEdgeInsets
    
    init(button: UIButton, margin: UIEdgeInsets) {
        self.button = button
        self.margin = margin
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addAutolayoutSubview(button)
        button.pinToSuperview(withEdges: margin)
        NSLayoutConstraint.activate([
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.ButtonHeight),
            ])
    }
}
