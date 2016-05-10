//
//  Created by Pierluigi Cifani on 10/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

extension UIViewController {

    public func showErrorMessage(message: String, error: ErrorType) {
        let operation = PresentAlertOperation(message: message, error: error, presentingViewController: self)
        operationQueue.addOperation(operation)
    }
}

private let operationQueue: NSOperationQueue = {
    let operationQueue = NSOperationQueue()
    operationQueue.maxConcurrentOperationCount = 1
    return operationQueue
}()

private class PresentAlertOperation: NSOperation {
    
    let message: String
    let error: ErrorType
    unowned let presentingViewController: UIViewController
    init(message: String, error: ErrorType, presentingViewController: UIViewController) {
        self.message = message
        self.error = error
        self.presentingViewController = presentingViewController
        super.init()
    }
    
    override func main() {
        
        guard cancelled == false else {
            self.executing = false
            self.finished = true
            return
        }
        
        self.executing = true
        self.finished = false

        NSOperationQueue.mainQueue().addOperationWithBlock {
        
            let alert = UIAlertController(title: "Error", message: self.message, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel) { _ in
                
                self.executing = false
                self.finished = true
            }
            
            alert.addAction(action)
            self.presentingViewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
    //Don't look here, it's disgusting
    var _finished = false
    var _executing = false

    override var executing:Bool {
        get { return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var finished:Bool {
        get { return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
}