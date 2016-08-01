//
//  Created by Pierluigi Cifani on 14/07/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

public struct ClassicProfileViewModel {
    public let photos: [Photo]
    public let titleInfo: NSAttributedString
    public let detailsInfo: NSAttributedString
    public let extraInfo: [NSAttributedString]
    
    public init(photos: [Photo], titleInfo: NSAttributedString, detailsInfo: NSAttributedString, extraInfo: [NSAttributedString]) {
        self.photos = photos
        self.titleInfo = titleInfo
        self.detailsInfo = detailsInfo
        self.extraInfo = extraInfo
    }
    
    func movePhotoAtIndex(index: Int, toIndex: Int) -> ClassicProfileViewModel {
        var photos = self.photos
        photos.moveItem(fromIndex: index, toIndex: toIndex)
        return ClassicProfileViewModel(
            photos: photos,
            titleInfo: titleInfo,
            detailsInfo: detailsInfo,
            extraInfo: extraInfo
        )
    }
}
