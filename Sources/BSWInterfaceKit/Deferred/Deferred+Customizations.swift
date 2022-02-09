import UIKit
import Task
import Deferred

// MARK: - ViewModel

@available(swift, deprecated: 5.6, obsoleted: 6.0, message: "Please use UIContentConfiguration instead")
public protocol AsyncViewModelPresenter: ViewModelConfigurable {
    var dataProvider: Task<VM>! { get set }
}

// MARK: - MediaPickerBehavior

public extension MediaPickerBehavior {
    
    func createVideoThumbnail(forURL videoURL: URL) -> Task<URL> {
        let deferred = Deferred<Task<URL>.Result>()
        _Concurrency.Task {
            do {
                let thumbnailURL = try await self.createVideoThumbnail(forURL: videoURL)
                deferred.fill(with: .success(thumbnailURL))
            } catch let error {
                deferred.fill(with: .failure(error))
            }
        }
        return Task(deferred)
    }
    
    func getMedia(_ kind: Kind = .photo, source: Source = .photoAlbum) -> (UIViewController?, Task<URL>) {
        let deferred = Deferred<Task<URL>.Result>()
        let vc = getMedia(kind, source: source) { (url) in
            if let url = url {
                deferred.fill(with: .success(url))
            } else {
                deferred.fill(with: .failure(Error.unknown))
            }
        }
        return (vc, Task(deferred))
    }
}

//MARK: - UIImageView

public typealias BSWImageCompletionBlock = (Swift.Result<UIImage, Swift.Error>) -> Void


// MARK: - UIViewController

public extension UIViewController {
    
    typealias TaskGenerator<T> = () -> (Task<T>)
    typealias TaskCompletion<T> = (T) -> ()
    
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
}
