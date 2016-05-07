//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import SDWebImage

public typealias BSWImageDownloaderProgressBlock = (Int, Int) -> Void
public typealias BSWImageCompletionBlock = (UIImage!, NSError!, SDImageCacheType, NSURL!) -> Void

extension UIImageView {

    private struct BSWImageOptions {
        private static let Default = SDWebImageOptions()
    }

    public func bsw_setImageFromURLString(url: String) {
        if let url = NSURL(string: url) {
            sd_setImageWithURL(url)
        }
    }

    public func bsw_setImageFromURL(url: NSURL) {
        sd_setImageWithURL(url)
    }
    
    public func bsw_cancelImageLoadFromURL() {
        sd_cancelCurrentImageLoad()
    }
    
    public func bsw_setImageWithURL(url: NSURL, progress progressBlock: BSWImageDownloaderProgressBlock, completed completedBlock: BSWImageCompletionBlock) {
        sd_setHighlightedImageWithURL(
            url,
            options: BSWImageOptions.Default,
            progress: progressBlock,
            completed: completedBlock
        )
    }
    
    public func bsw_setPhoto(photo: Photo) {
        switch photo.kind {
        case .Image(let image):
            self.image = image
        case .URL(let url):
            backgroundColor = photo.averageColor
            bsw_setImageFromURL(url)
        }
    }
}

