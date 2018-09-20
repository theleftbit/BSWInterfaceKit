//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import SDWebImage
import BSWFoundation
import Deferred

public typealias BSWImageCompletionBlock = (Task<UIImage>.Result) -> Void

extension UIImageView {

    private static var webDownloadsEnabled = true

    @objc(bsw_disableWebDownloads)
    static public func disableWebDownloads() {
        webDownloadsEnabled = false
    }

    @objc(bsw_enableWebDownloads)
    static public func enableWebDownloads() {
        webDownloadsEnabled = false
    }

    @objc(bsw_setImageFromURLString:)
    public func setImageFromURLString(_ url: String) {
        if let url = URL(string: url) {
            setImageWithURL(url)
        }
    }

    @objc(bsw_cancelImageLoadFromURL)
    public func cancelImageLoadFromURL() {
        sd_cancelCurrentImageLoad()
    }

    @nonobjc
    public func setImageWithURL(_ url: URL, completed completedBlock: BSWImageCompletionBlock? = nil) {
        guard UIImageView.webDownloadsEnabled else { return }
        sd_setImage(with: url) { (image, error, _, _) in

            let result: Task<UIImage>.Result
            if let image = image {
                result = .success(image)
            } else if let error = error {
                result = .failure(error)
            } else {
                result = .failure(NSError(domain: "com.bswinterfacekit.uiimageview", code: 0, userInfo: nil))
            }
            
            completedBlock?(result)
        }
    }

    @nonobjc
    public func setPhoto(_ photo: Photo) {
        switch photo.kind {
        case .image(let image):
            self.image = image
        case .url(let url):
            backgroundColor = photo.averageColor
            setImageWithURL(url) { result in
                guard result.error == nil else { return }
                self.image = result.value
                self.backgroundColor = nil
            }
        case .empty:
            image = nil
            backgroundColor = photo.averageColor
        }
    }
    
    public static func prefetchImagesAtURL(_ urls: [URL]) {
        SDWebImagePrefetcher.shared().prefetchURLs(urls)
    }
}

