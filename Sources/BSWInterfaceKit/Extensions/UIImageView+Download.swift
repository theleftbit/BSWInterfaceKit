//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#if canImport(UIKit)

import BSWFoundation
import Task
import Nuke
import UIKit

public typealias BSWImageCompletionBlock = (Task<UIImage>.Result) -> Void

extension UIImageView {

    public static var fadeImageDuration: TimeInterval? = nil

    private static var webDownloadsEnabled = true

    @objc(bsw_disableWebDownloads)
    static public func disableWebDownloads() {
        webDownloadsEnabled = false
    }

    @objc(bsw_enableWebDownloads)
    static public func enableWebDownloads() {
        webDownloadsEnabled = true
    }

    @objc(bsw_setImageFromURLString:)
    public func setImageFromURLString(_ url: String) {
        if let url = URL(string: url) {
            setImageWithURL(url)
        }
    }

    @objc(bsw_cancelImageLoadFromURL)
    public func cancelImageLoadFromURL() {
        Nuke.cancelRequest(for: self)
    }
    
    enum Errors: Swift.Error {
        case unknown
    }
    
    @discardableResult
    public func setImageWithURL(_ url: URL) async throws -> UIImage {
        guard UIImageView.webDownloadsEnabled else { throw Errors.unknown }
        
        let options = ImageLoadingOptions(
            transition: (UIImageView.fadeImageDuration != nil) ? .fadeIn(duration: UIImageView.fadeImageDuration!) : nil
        )
        
        return try await withCheckedThrowingContinuation({ continuation in
            Nuke.loadImage(with: url, options: options, into: self, progress: nil) { (result) in
                switch result {
                case .failure(let error):
                    continuation.resume(throwing: error)
                case .success(let response):
                    continuation.resume(returning: response.image)
                }
            }
        })
    }

    @nonobjc
    public func setImageWithURL(_ url: URL, completed completedBlock: BSWImageCompletionBlock? = nil) {
        _Concurrency.Task {
            do {
                let result = try await self.setImageWithURL(url)
                completedBlock?(.success(result))
            } catch let error {
                completedBlock?(.failure(error))
            }
        }
    }

    @nonobjc
    public func setPhoto(_ photo: Photo) {
        if let preferredContentMode = photo.preferredContentMode {
            contentMode = preferredContentMode
        }
        switch photo.kind {
        case .image(let image):
            self.image = image
        case .url(let url, let _placeholderImage):
            if let placeholderImage = _placeholderImage {
                image = placeholderImage.image
                contentMode = placeholderImage.preferredContentMode
            }
            backgroundColor = photo.averageColor
            setImageWithURL(url) { result in
                switch result {
                case .failure:
                    if let placeholderImage = _placeholderImage {
                        self.image = placeholderImage.image
                        self.contentMode = placeholderImage.preferredContentMode
                    }
                case .success:
                    if let preferredContentMode = photo.preferredContentMode {
                        self.contentMode = preferredContentMode
                    }
                    self.backgroundColor = nil
                }
            }
        case .empty:
            image = nil
            backgroundColor = photo.averageColor
        }
    }
    
    public static func prefetchImagesAtURL(_ urls: [URL]) {
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        preheater.startPrefetching(with: urls)
    }
}

private let preheater = Nuke.ImagePrefetcher(destination: .diskCache)

#endif
