//
//  Created by Pierluigi Cifani on 19/08/2019.
//  Copyright © 2019 The Left Bit. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import BSWFoundation

public extension UIViewController {

    typealias LoadingViewFactory = () -> (UIView)
    typealias ErrorViewFactory = (String, Error, @escaping VoidHandler) -> (UIView)

    typealias SwiftConcurrencyGenerator<T> = () async throws -> (T)
    typealias SwiftConcurrencyCompletion<T> = (T) async -> ()

    /**
     Allows you to show a loading/error/success state in any `UIViewController`.
     Please customize it via `loadingViewFactory` and `errorViewFactory`
      - Parameters:
        - taskGenerator: a closure that runs a returns a `T`. Can be `async throws`
        - animated: Indicates where the first transition to the loading phase is animated. All other transitions are animated by default.
        - errorMessage: An optional error message to pass to `ErrorViewFactory` in case an error happens
        - completion: A completion handler where the Success value is retrieved. Use it to configure your `viewController`.
     */
    @discardableResult
    @MainActor
    func fetchData<T>(taskGenerator: @escaping SwiftConcurrencyGenerator<T>, animated: Bool = true, errorMessage: String = "error", completion: @escaping SwiftConcurrencyCompletion<T>) -> Task<(), Never> {
        bsw_showLoadingView(animated: animated)
        let task = Task(priority: .userInitiated) {
            do {
                let value = try await taskGenerator()
                try Task.checkCancellation()
                await completion(value)
                bsw_hideLoadingView(animated: self.defaultAnimationFlag)
            } catch is CancellationError {
                bsw_hideLoadingView(animated: self.defaultAnimationFlag)
            } catch {
                if error.isURLCancelled { /* Don't show the error in case it's a search */ return }
                bsw_hideLoadingView(animated: self.defaultAnimationFlag)
                handleError(
                    error,
                    errorMessage: errorMessage,
                    taskGenerator: taskGenerator,
                    animated: defaultAnimationFlag,
                    completion: completion
                )
            }
            self.bswFetchTask = nil
        }
        self.bswFetchTask = task
        return task
    }

    private enum AssociatedKeys {
        static var FetchTask = "BSWFetchTask"
    }
    
    @MainActor
    var closestBSWFetchTask: Task<(), Never>? {
        if let bswFetchTask {
            return bswFetchTask
        } else {
            return children.compactMap { $0.bswFetchTask }.first
        }
    }
    
    @MainActor
    private var bswFetchTask: Task<(), Never>? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.FetchTask) as? TaskWrapper)?.fetchTask
        } set {
            if let task = newValue {
                let taskWrapper = TaskWrapper(fetchTask: task)
                objc_setAssociatedObject(self, &AssociatedKeys.FetchTask, taskWrapper, .OBJC_ASSOCIATION_RETAIN)
            } else {
                objc_setAssociatedObject(self, &AssociatedKeys.FetchTask, nil, .OBJC_ASSOCIATION_RETAIN)
            }
        }
    }
        
    @MainActor
    func handleError<T>(_ error: Swift.Error, errorMessage: String, taskGenerator: @escaping SwiftConcurrencyGenerator<T>, animated: Bool, completion: @escaping SwiftConcurrencyCompletion<T>) {
        let localizedErrorMessage = (errorMessage == "error") ? errorMessage.localized : errorMessage
        let errorView = UIViewController.errorViewFactory(localizedErrorMessage, error) { [weak self] in
            self?.hideError(animated: animated)
            self?.fetchData(taskGenerator: taskGenerator, animated: animated, errorMessage: localizedErrorMessage, completion: completion)
        }
        self.showErrorView(errorView, animated: animated)
    }

    @MainActor
    @objc func bsw_showLoadingView(animated: Bool) {
        showLoadingView(UIViewController.loadingViewFactory(), animated: animated)
    }
    
    @MainActor
    @objc func bsw_hideLoadingView(animated: Bool) {
        hideLoader(animated: animated)
    }
    
    internal var defaultAnimationFlag: Bool {
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

private class TaskWrapper: NSObject {
    
    let fetchTask: Task<(), Never>
    init(fetchTask: Task<(), Never>) {
        self.fetchTask = fetchTask
        super.init()
    }
}

#endif
