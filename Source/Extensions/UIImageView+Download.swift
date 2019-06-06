//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import BSWFoundation
import Deferred
import Nuke

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

    @nonobjc
    public func setImageWithURL(_ url: URL, completed completedBlock: BSWImageCompletionBlock? = nil) {
        guard UIImageView.webDownloadsEnabled else { return }
        
        let options = ImageLoadingOptions(
            transition: (UIImageView.fadeImageDuration != nil) ? .fadeIn(duration: UIImageView.fadeImageDuration!) : nil
        )
        Nuke.loadImage(with: url, options: options, into: self) { (response, error) in

            let result: Task<UIImage>.Result
            if let image = response?.image {
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
        preheater.startPreheating(with: urls)
    }
}

private let preheater = Nuke.ImagePreheater(destination: .diskCache)
