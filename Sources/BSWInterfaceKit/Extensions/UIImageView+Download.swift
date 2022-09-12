//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#if canImport(UIKit)

import BSWFoundation
import Nuke
import UIKit

extension UIImageView {

//    public static var fadeImageDuration: TimeInterval? = nil

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
            Task {
                try await setImageWithURL(url)
            }
        }
    }

    @objc(bsw_cancelImageLoadFromURL)
    public func cancelImageLoadFromURL() {
        ImagePipeline.shared.invalidate()
    }
    
    enum ImageDownloadError: Swift.Error {
        case webDownloadsDisabled
    }

    @nonobjc
    public func setImageWithURL(_ url: URL) async throws {
        guard UIImageView.webDownloadsEnabled else { return }
        
        let request = ImageRequest(
            url: url,
            processors: [],
            priority: .normal,
            options: [.reloadIgnoringCachedData]
        )
        let response = try await ImagePipeline.shared.image(for: request)
        self.image = response.image
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
            Task {
                do {
                    try await setImageWithURL(url)
                    if let preferredContentMode = photo.preferredContentMode {
                        self.contentMode = preferredContentMode
                    }
                    self.backgroundColor = nil
                } catch {
                    if let placeholderImage = _placeholderImage {
                        self.image = placeholderImage.image
                        self.contentMode = placeholderImage.preferredContentMode
                    }
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
