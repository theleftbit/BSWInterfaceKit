//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#if canImport(UIKit)

import BSWFoundation
import Nuke; import NukeExtensions
import UIKit

extension UIImageView {

    @MainActor
    public static var fadeImageDuration: TimeInterval? = nil

    @MainActor
    private static var webDownloadsEnabled = true
    
    public typealias BSWImageCompletionBlock = (Swift.Result<UIImage, Swift.Error>) -> Void

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
        NukeExtensions.cancelRequest(for: self)
    }
    
    enum ImageDownloadError: Swift.Error {
        case webDownloadsDisabled
    }

    @nonobjc
    public func setImageWithURL(_ url: URL, completed completedBlock: BSWImageCompletionBlock? = nil) {
        guard UIImageView.webDownloadsEnabled else { return }

        let options = ImageLoadingOptions(
            transition: (UIImageView.fadeImageDuration != nil) ? .fadeIn(duration: UIImageView.fadeImageDuration!) : nil
        )
        
        NukeExtensions.loadImage(with: url, options: options, into: self) { (result) in
            let taskResult: Swift.Result<UIImage, Swift.Error>
            switch result {
            case .failure(let error):
                taskResult = .failure(error)
            case .success(let response):
                taskResult = .success(response.image)
            }
            completedBlock?(taskResult)
        }
    }
    
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
