//
//  Created by Pierluigi Cifani on 10/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

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

private let errorQueue: OperationQueue = {
  let operationQueue = OperationQueue()
  operationQueue.maxConcurrentOperationCount = 1
  return operationQueue
}()
