//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import SDWebImage

extension UIImageView {

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
}

