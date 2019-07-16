//
//  Created by Pierluigi Cifani on 07/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit
import Nuke

public struct Photo: Equatable {
    
    public enum Kind: Equatable {
        case url(Foundation.URL, placeholderImage: PlaceholderImage?)
        case image(UIImage)
        case empty
    }
    
    public let kind: Kind
    public let averageColor: UIColor
    public let size: CGSize?
    public let preferredContentMode: UIView.ContentMode?

    public init(kind: Kind, averageColor: UIColor = UIColor.randomColor(), size: CGSize? = nil, preferredContentMode: UIView.ContentMode? = nil) {
        self.kind = kind
        self.averageColor = averageColor
        self.preferredContentMode = preferredContentMode
        self.size = size
    }

    public init(image: UIImage, averageColor: UIColor = UIColor.randomColor(), preferredContentMode: UIView.ContentMode? = nil) {
        self.kind = .image(image)
        self.averageColor = averageColor
        self.preferredContentMode = preferredContentMode
        self.size = image.size
    }

    public init(url: URL?, averageColor: UIColor = UIColor.randomColor(), placeholderImage: PlaceholderImage? = nil, size: CGSize? = nil, preferredContentMode: UIView.ContentMode? = nil) {
        self.kind = (url == nil) ? .empty : .url(url!, placeholderImage: placeholderImage)
        self.averageColor = averageColor
        self.preferredContentMode = preferredContentMode
        self.size = size
    }
    
    public static func emptyPhoto() -> Photo {
        return Photo(kind: .empty, averageColor: UIColor.randomColor(), size: nil)
    }
}

public enum RandomColorFactory {

    public static var isOn: Bool = true
    public static var defaultColor = UIColor.init(r: 255, g: 149, b: 0)
    
    public static func randomColor() -> UIColor {
        guard isOn else {
            return defaultColor
        }

        let randomRed:CGFloat = CGFloat(drand48())
        let randomGreen:CGFloat = CGFloat(drand48())
        let randomBlue:CGFloat = CGFloat(drand48())
        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
    }
}

public extension Photo {
    var estimatedSize: CGSize? {
        guard size == nil else {
            return size
        }

        return self.uiImage?.size
    }
    
    var uiImage: UIImage? {
        switch self.kind {
        case .empty:
            return nil
        case .image(let image):
            return image
        case .url(let url, _):
            let imageCache = Nuke.ImageCache.shared //This dependency should be removed
            guard let request = imageCache.cachedResponse(for: ImageRequest(url: url)) else {
                return nil
            }
            return request.image
        }
    }

    var url: URL? {
        switch self.kind {
        case .empty:
            return nil
        case .image:
            return nil
        case .url(let url, _):
            return url
        }
    }
}

public extension Photo {
    struct PlaceholderImage: Equatable {
        public let image: UIImage
        public let preferredContentMode: UIView.ContentMode
        public init(image: UIImage, preferredContentMode: UIView.ContentMode) {
            self.image = image
            self.preferredContentMode = preferredContentMode
        }
    }
}

extension Photo {
    static func samplePhotos() -> [Photo] {
        let photo1 = Photo(url: URL(string: "http://e2.365dm.com/15/09/768x432/alessandro-del-piero-juventus-serie-a_3351343.jpg?20150915122301")!)
        let photo2 = Photo(url: URL(string: "http://images1.fanpop.com/images/photos/2000000/Old-Golden-Days-alessandro-del-piero-2098417-600-705.jpg")!)
        let photo3 = Photo(url: URL(string: "http://e0.365dm.com/14/05/768x432/Alessandro-del-Piero-italy-2002_3144508.jpg?20140520095830")!)
        let photo4 = Photo(url: URL(string: "http://static.goal.com/576000/576031_heroa.jpg")!)
        return [photo1, photo2, photo3, photo4]
    }
}
