import UIKit
import Task
import Deferred

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
