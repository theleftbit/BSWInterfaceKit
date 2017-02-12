//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import PINRemoteImage
import BSWFoundation
import Deferred

public typealias BSWImageCompletionBlock = (TaskResult<UIImage>) -> Void

extension UIImageView {

    private static var webDownloadsEnabled = true

    static public func bsw_disableWebDownloads() {
        webDownloadsEnabled = false
    }

    static public func bsw_enableWebDownloads() {
        webDownloadsEnabled = false
    }

    public func bsw_setImageFromURLString(_ url: String) {
        if let url = URL(string: url) {
            bsw_setImageWithURL(url)
        }
    }

    public func bsw_cancelImageLoadFromURL() {
        pin_cancelImageDownload()
    }
    
    public func bsw_setImageWithURL(_ url: URL, completed completedBlock: BSWImageCompletionBlock? = nil) {
        guard UIImageView.webDownloadsEnabled else { return }
        pin_setImage(from: url) { (downloadResult) in

            let result: TaskResult<UIImage>
            if let image = downloadResult.image {
                result = .success(image)
            } else if let error = downloadResult.error {
                result = .failure(error)
            } else {
                result = .failure(NSError(domain: "com.bswinterfacekit.uiimageview", code: 0, userInfo: nil))
            }
            
            completedBlock?(result)
        }
    }
    
    public func bsw_setPhoto(_ photo: Photo) {
        switch photo.kind {
        case .image(let image):
            self.image = image
        case .url(let url):
            backgroundColor = photo.averageColor
            bsw_setImageWithURL(url) { result in
                guard result.error == nil else { return }
                self.image = result.value
                self.backgroundColor = nil
            }
        case .empty:
            backgroundColor = photo.averageColor
        }
    }
}

