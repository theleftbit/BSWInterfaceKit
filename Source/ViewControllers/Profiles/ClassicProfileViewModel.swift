//
//  Created by Pierluigi Cifani on 14/07/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
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
}

// MARK: - Photo handling

extension ClassicProfileViewModel {
    func movingPhotoAtIndex(_ index: Int, toIndex: Int) -> ClassicProfileViewModel {
        var photos = self.photos
        photos.moveItem(fromIndex: index, toIndex: toIndex)
        return ClassicProfileViewModel(
            photos: photos,
            titleInfo: titleInfo,
            detailsInfo: detailsInfo,
            extraInfo: extraInfo
        )
    }
    
    func removingPhotoAtIndex(_ index: Int) -> ClassicProfileViewModel {
        var photos = self.photos
        photos.remove(at: index)
        return ClassicProfileViewModel(
            photos: photos,
            titleInfo: titleInfo,
            detailsInfo: detailsInfo,
            extraInfo: extraInfo
        )
    }
}

// MARK: - Sample Profiles

extension ClassicProfileViewModel {
    public static func buffon() -> ClassicProfileViewModel {
        return ClassicProfileViewModel(
            photos: [
                Photo(url: URL(string: "https://i.imgur.com/Y9u82wp.jpg")!),
                Photo(url: URL(string: "https://i.imgur.com/SdCC8XG.jpg")!)
            ],
            titleInfo: TextStyler.styler.attributedString("Gianluigi Buffon", forStyle: .title1),
            detailsInfo: TextStyler.styler.attributedString("The best keeper of football history", forStyle: .body),
            extraInfo: [
                TextStyler.styler.attributedString("1 World Cup 2006", forStyle: .body),
                TextStyler.styler.attributedString("7 Serie A titles", forStyle: .body),
                TextStyler.styler.attributedString("3 Coppa Italia", forStyle: .body),
                TextStyler.styler.attributedString("1 Uefa Cup", forStyle: .body)
            ]
        )
    }
}
