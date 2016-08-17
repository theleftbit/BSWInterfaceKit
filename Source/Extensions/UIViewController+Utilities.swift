//
//  Created by Pierluigi Cifani on 10/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation
import Cartography

extension UIWindow {
    public func showErrorMessage(message: String, error: ErrorType) {
        guard let rootViewController = self.visibleViewController else { return }
        rootViewController.showErrorMessage(message, error: error)
    }
}

extension UIViewController {

    public func showErrorMessage(message: String, error: ErrorType) {
        
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

    public func addBottomActionButton(buttonConfig: ButtonConfiguration) {
    
        guard traitCollection.horizontalSizeClass == .Compact else { fatalError() }
        
        func animateChanges(changes: () -> ()) {
            UIView.animateWithDuration(
                Constants.ButtonAnimationDuration,
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
            bottomConstraint?.constant = CGRectGetHeight(button.bounds)
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
    private static let BottomActionTag = 345678
    private static let ButtonAnimationDuration = 0.6
    private static let ButtonHeight = CGFloat(50)
}

private let errorQueue: NSOperationQueue = {
    let operationQueue = NSOperationQueue()
    operationQueue.maxConcurrentOperationCount = 1
    return operationQueue
}()

private class PresentAlertOperation: NSOperation {
    
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
        
        guard cancelled == false else {
            self.finishOperation()
            return
        }
        
        self.executing = true
        self.finished = false

        NSOperationQueue.mainQueue().addOperationWithBlock {
        
            guard let _ = self.presentingViewController.view.window else {
                self.finishOperation()
                return
            }
            
            let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel) { _ in
                self.finishOperation()
            }
            
            alert.addAction(action)
            self.presentingViewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    //Don't look here, it's disgusting
    var _finished = false
    var _executing = false

    override var executing: Bool {
        get {
            return _executing
        }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var finished: Bool {
        get {
            return _finished
        }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    private func finishOperation() {
        self.executing = false
        self.finished = true
    }
}