//
//  Created by Pierluigi Cifani on 07/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import Nuke

/// This represents an image to be displayed in the app.
///
/// Please do not use this to represent Symbols, but rather large Bitmaps.
public struct Photo {
    
    
    /// The source of the Photo.
    public enum Kind {
        /// The Photo is in a remote URL and there's an Optional `PlaceholderImage` to be shown while the Photo is loading.
        case url(Foundation.URL, placeholderImage: PlaceholderImage?)
        
        /// There's a `UIImage` representing this Photo.
        case image(UIImage)
        
        /// Just an empty Photo.
        case empty
    }
    
    /// The source of the Photo
    public let kind: Kind
    
    /// The averageColor of the `Photo`. Will be shown during loading if appropiate.
    public let averageColor: UIColor
    
    /// The size of the image if known
    public let size: CGSize?
    
    /// The `UIView.ContentMode` that will be used to display the `Photo`
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
    
    
    /// Generates a random pastel color
    /// - Returns: a UIColor
    public static func randomColor() -> UIColor {
        guard isOn else {
            return defaultColor
        }
        /// Source: https://twitter.com/manuelmaly/status/1523335860258705408
        return UIColor(
            hue: .random(in: 0.0...1.0),
            saturation: .random(in: 0.2...0.55),
            brightness: 0.9,
            alpha: 1
        )
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
            // This dependency should be removed
            let imageCache = ImagePipeline.shared.cache
            guard let request = imageCache[ImageRequest(url: url)] else {
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
    struct PlaceholderImage {
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

extension CGSize: Hashable { // For some reason `CGSize` isn't `Hashable`
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
}
extension Photo: Equatable, Hashable {}
extension Photo.Kind: Equatable, Hashable {}
extension Photo.PlaceholderImage: Equatable, Hashable {}
#endif
