//
//  Created by Pierluigi Cifani on 10/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation
import Cartography

extension UIWindow {
    public func showErrorMessage(_ message: String, error: Error) {
        guard let rootViewController = self.visibleViewController else { return }
        rootViewController.showErrorMessage(message, error: error)
    }
}

extension UIViewController {

    public func showErrorMessage(_ message: String, error: Error) {
        
        #if DEBUG
            let errorMessage = "\(message). \(error)"
        #else
            let errorMessage = message
        #endif
        
        let operation = PresentAlertOperation(title: "Error", message: errorMessage, presentingViewController: self)
        errorQueue.addOperation(operation)
    }

    public func showTodoMessage() {
        let operation = PresentAlertOperation(title: "ToDo", message: nil, presentingViewController: self)
        errorQueue.addOperation(operation)
    }

    public func addBottomActionButton(_ buttonConfig: ButtonConfiguration) {
    
        guard traitCollection.horizontalSizeClass == .compact else { fatalError() }
        
        func animateChanges(_ changes: @escaping () -> ()) {
            UIView.animate(
                withDuration: Constants.ButtonAnimationDuration,
                delay: 0,
                usingSpringWithDamping: 0.7,
                initialSpringVelocity: 0.3,
                options: UIViewAnimationOptions(),
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
            view.addSubview(button)
            
            var bottomConstraint: NSLayoutConstraint?
            
            constrain(button) { button in
                button.height >= Constants.ButtonHeight
                bottomConstraint = (button.bottom == button.superview!.bottom)
                button.leading == button.superview!.leading
                button.trailing == button.superview!.trailing
            }

            view.layoutIfNeeded()

            //Now, let's animate how this is shown
            bottomConstraint?.constant = button.bounds.height
            view.layoutIfNeeded()
            bottomConstraint?.constant = 0
            animateChanges {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    public func removeBottonActionButton() {
        view.removeSubviewWithTag(Constants.BottomActionTag)
    }
}

// MARK: Private

private enum Constants {
    fileprivate static let BottomActionTag = 345678
    fileprivate static let ButtonAnimationDuration = 0.6
    fileprivate static let ButtonHeight = CGFloat(50)
}

private let errorQueue: OperationQueue = {
    let operationQueue = OperationQueue()
    operationQueue.maxConcurrentOperationCount = 1
    return operationQueue
}()

private class PresentAlertOperation: Operation {
    
    let title: String
    let message: String?
    unowned let presentingViewController: UIViewController
    init(title: String, message: String?, presentingViewController: UIViewController) {
        self.title = title
        self.message = message
        self.presentingViewController = presentingViewController
        super.init()
    }
    
    override func main() {
        
        guard isCancelled == false else {
            self.finishOperation()
            return
        }
        
        self.isExecuting = true
        self.isFinished = false

        OperationQueue.main.addOperation {
        
            guard let _ = self.presentingViewController.view.window else {
                self.finishOperation()
                return
            }
            
            let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel) { _ in
                self.finishOperation()
            }
            
            alert.addAction(action)
            self.presentingViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    
    //Don't look here, it's disgusting
    var _finished = false
    var _executing = false

    override var isExecuting: Bool {
        get {
            return _executing
        }
        set {
            willChangeValue(forKey: "isExecuting")
            _executing = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isFinished: Bool {
        get {
            return _finished
        }
        set {
            willChangeValue(forKey: "isFinished")
            _finished = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    fileprivate func finishOperation() {
        self.isExecuting = false
        self.isFinished = true
    }
}
