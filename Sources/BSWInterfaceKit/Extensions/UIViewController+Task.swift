//
//  Created by Pierluigi Cifani on 19/08/2019.
//  Copyright © 2019 The Left Bit. All rights reserved.
//

import UIKit
import Task
import BSWFoundation

public extension UIViewController {

    typealias TaskGenerator<T> = () -> (Task<T>)
    typealias TaskCompletion<T> = (T) -> ()

    typealias LoadingViewFactory = () -> (UIView)
    typealias ErrorViewFactory = (String, Error, @escaping VoidHandler) -> (UIView)

    @discardableResult
    func fetchData<T>(taskGenerator: @escaping TaskGenerator<T>, animated: Bool = true, errorMessage: String = "error", completion: @escaping TaskCompletion<T>) -> Task<T> {
        bsw_showLoadingView(animated: animated)
        let task = taskGenerator()
        task.upon(.main) { [weak self] (result) in
            self?.bsw_hideLoadingView()
            switch result {
            case .failure(let error):
                if error.isURLCancelled { /* Don't show the error in case it's a search */ return }
                self?.handleError(error, errorMessage: errorMessage, taskGenerator: taskGenerator, animated: animated, completion: completion)
            case .success(let value):
                completion(value)
            }
        }
        return task
    }

    private func handleError<T>(_ error: Swift.Error, errorMessage: String, taskGenerator: @escaping TaskGenerator<T>, animated: Bool, completion: @escaping TaskCompletion<T>) {
        let localizedErrorMessage = (errorMessage == "error") ? errorMessage.localized : errorMessage
        let errorView = UIViewController.errorViewFactory(localizedErrorMessage, error) { [weak self] in
            self?.hideError(animated: animated)
            self?.fetchData(taskGenerator: taskGenerator, animated: animated, errorMessage: localizedErrorMessage, completion: completion)
        }
        self.showErrorView(errorView, animated: animated)
    }
    
    @objc func bsw_showLoadingView(animated: Bool) {
        showLoadingView(UIViewController.loadingViewFactory(), animated: animated)
    }
    
    @objc func bsw_hideLoadingView() {
        hideLoader()
    }
    
    static var loadingViewFactory: LoadingViewFactory = { LoadingView() }
    static var errorViewFactory: ErrorViewFactory = { ErrorView.retryView(message: $0, error: $1, onRetry: $2) }
}
