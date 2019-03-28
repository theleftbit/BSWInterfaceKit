//
//  Created by Pierluigi Cifani on 20/03/2017.
//

import Foundation

class PresentAlertOperation: Operation {

    let title: String?
    let message: String?
    weak var presentingViewController: UIViewController?
    init(title: String?, message: String?, presentingViewController: UIViewController) {
        self.title = title
        self.message = message
        self.presentingViewController = {
            //Find the parent in the hierarchy
            var parentVC: UIViewController! = presentingViewController
            while parentVC.parent != nil {
                parentVC = parentVC.parent
            }
            return parentVC
        }()
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
            
            guard let presentingViewController = self.presentingViewController, let _ = presentingViewController.view.window else {
                self.finishOperation()
                return
            }

            let alert = UIAlertController(title: self.title, message: self.message, preferredStyle: .alert)
            let action = UIAlertAction(title: BSWInterfaceKitStrings.dismiss.string, style: .cancel) { _ in
                self.finishOperation()
            }

            alert.addAction(action)
            presentingViewController.present(alert, animated: true, completion: nil)
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

    private func finishOperation() {
        self.isExecuting = false
        self.isFinished = true
    }
}
