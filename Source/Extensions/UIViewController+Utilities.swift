//
//  Created by Pierluigi Cifani on 10/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

// MARK: - Presenting and dismissing

extension UIViewController {

    @objc(bsw_showErrorAlert:error:)
    public func showErrorAlert(_ message: String, error: Error) {
        
        #if DEBUG
        let errorMessage = "\(message) \n\n Error code: \(error.localizedDescription)"
        #else
        let errorMessage = message
        #endif
        
        let operation = PresentAlertOperation(title: "Error", message: errorMessage, presentingViewController: self)
        errorQueue.addOperation(operation)
    }
    
    @objc(bsw_showTodoMessage)
    public func showTodoAlert() {
        let operation = PresentAlertOperation(title: "ToDo", message: nil, presentingViewController: self)
        errorQueue.addOperation(operation)
    }    

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

private let errorQueue: OperationQueue = {
  let operationQueue = OperationQueue()
  operationQueue.maxConcurrentOperationCount = 1
  return operationQueue
}()
