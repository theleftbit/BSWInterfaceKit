//
//  Created by Pierluigi Cifani on 19/08/2019.
//  Copyright © 2019 The Left Bit. All rights reserved.
//

import UIKit
import Task
import BSWFoundation

@available(iOSApplicationExtension, unavailable)
public extension UIViewController {

    typealias TaskGenerator<T> = () -> (Task<T>)
    typealias TaskCompletion<T> = (T) -> ()

    typealias LoadingViewFactory = () -> (UIView)
    typealias ErrorViewFactory = (String, Error, @escaping VoidHandler) -> (UIView)

    /**
     Allows you to show a loading/error/success state in any `UIViewController`.
     Please customize it via `loadingViewFactory` and `errorViewFactory`
      - Parameters:
        - taskGenerator: a closure that returns a `Task` that fetches the data
        - animated: Indicates where the first transition to the loading phase is animated. All other transitions are animated by default.
        - errorMessage: An optional error message to pass to `ErrorViewFactory` in case an error happens
        - completion: A completion handler where the Success value is retrieved. Use it to configure your `viewController`.
     */
    @discardableResult
    func fetchData<T>(taskGenerator: @escaping TaskGenerator<T>, animated: Bool = true, errorMessage: String = "error", completion: @escaping TaskCompletion<T>) -> Task<T> {
        bsw_showLoadingView(animated: animated)
        let task = taskGenerator()
        task.upon(.main) { [weak self] (result) in
            guard let self = self else { return }
            self.bsw_hideLoadingView(animated: self.defaultAnimationFlag)
            switch result {
            case .failure(let error):
                if error.isURLCancelled { /* Don't show the error in case it's a search */ return }
                self.handleError(error, errorMessage: errorMessage, taskGenerator: taskGenerator, animated: self.defaultAnimationFlag, completion: completion)
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
    
    @objc func bsw_hideLoadingView(animated: Bool) {
        hideLoader(animated: animated)
    }
    
    private var defaultAnimationFlag: Bool {
        #if DEBUG
        if UIApplication.shared.isRunningTests {
            return false
        } else {
            return true
        }
        #else
        return true
        #endif
    }
    
    static var loadingViewFactory: LoadingViewFactory = { LoadingView() }
    static var errorViewFactory: ErrorViewFactory = { ErrorView.retryView(message: $0, error: $1, onRetry: $2) }
}
