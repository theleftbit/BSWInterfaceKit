//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#if canImport(UIKit.UIImageView)

import BSWFoundation
import Nuke
import UIKit
import SwiftUI
import ObjectiveC

@MainActor
extension UIImageView {

    private static var bsw_cancellableKey: UInt8 = 0

    private var bsw_imageDownloadCancellable: Cancellable? {
        get {
            objc_getAssociatedObject(self, &UIImageView.bsw_cancellableKey) as? Cancellable
        }
        set {
            objc_setAssociatedObject(self, &UIImageView.bsw_cancellableKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public static var fadeImageDuration: TimeInterval? = nil

    private nonisolated(unsafe) static var webDownloadsEnabled = true
    
    public typealias BSWImageCompletionBlock = (Swift.Result<UIImage, Swift.Error>) -> Void

    @objc(bsw_disableWebDownloads)
    static nonisolated public func disableWebDownloads() {
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
        bsw_imageDownloadCancellable?.cancel()
        bsw_imageDownloadCancellable = nil
    }
    
    enum ImageDownloadError: Swift.Error {
        case webDownloadsDisabled
    }

    @nonobjc
    public func setImageWithURL(_ url: URL, completed completedBlock: BSWImageCompletionBlock? = nil) {
        guard UIImageView.webDownloadsEnabled else {
            completedBlock?(.failure(CancellationError()))
            return
        }

        let task = ImagePipeline.shared.loadImage(with: url) { [weak self] result in
            let taskResult: Swift.Result<UIImage, Swift.Error>
            switch result {
            case .failure(let error):
                taskResult = .failure(error)
            case .success(let response):
                self?.image = response.image
                taskResult = .success(response.image)
            }
            completedBlock?(taskResult)
        }

        bsw_imageDownloadCancellable = task
    }

    public func setPhoto(_ photo: Photo, preferredContentMode: UIView.ContentMode? = nil, placeholderImage: UIImage? = nil) {
        if let preferredContentMode = preferredContentMode {
            contentMode = preferredContentMode
        }
        switch photo.kind {
        case .image(let image):
            self.image = {
                let renderer = ImageRenderer(content: image)
                renderer.scale = UIScreen.main.scale
                if let uiImage = renderer.uiImage {
                    return uiImage
                } else {
                    return nil
                }
            }()
        case .url(let url):
            if let placeholderImage {
                image = placeholderImage
            }
            backgroundColor = UIColor(photo.averageColor)
            setImageWithURL(url) { result in
                switch result {
                case .failure:
                    if let placeholderImage {
                        self.image = placeholderImage
                    }
                case .success:
                    if let preferredContentMode {
                        self.contentMode = preferredContentMode
                    }
                    self.backgroundColor = nil
                }
            }
        case .empty:
            image = nil
            backgroundColor = UIColor(photo.averageColor)
        }
    }
    
    public static func prefetchImagesAtURL(_ urls: [URL]) {
        guard ProcessInfo.processInfo.isLowPowerModeEnabled == false else { return }
        preheater.startPrefetching(with: urls)
    }
}

private let preheater = Nuke.ImagePrefetcher(destination: .diskCache)
extension Nuke.ImageTask: @retroactive Cancellable {}

#endif
