//
//  Created by Pierluigi Cifani on 07/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

#if os(Android)
import SkipFuseUI
#else
import SwiftUI
#endif

/// This represents an image to be displayed in the app.
///
/// Please do not use this to represent Symbols, but rather large Bitmaps.
public struct Photo {
    
    /// The source of the Photo.
    public enum Kind {
        /// The Photo is in a remote URL.
        case url(Foundation.URL)
        
        /// There's a `SwiftUI.Image` representing this Photo.
        case image(Image)
        
        /// Just an empty Photo.
        case empty
    }
    
    /// The source of the Photo
    public let kind: Kind
    
    /// The averageColor of the `Photo`. Will be shown during loading if appropiate.
    public let averageColor: Color
    
    /// The size of the image if known
    public let size: CGSize?
    
    public init(kind: Kind, averageColor: Color = .randomColor(), size: CGSize? = nil) {
        self.kind = kind
        self.averageColor = averageColor
        self.size = size
    }

    public init(image: Image, averageColor: Color = .randomColor()) {
        self.kind = .image(image)
        self.averageColor = averageColor
        self.size = nil
    }

    #if canImport(UIKit.UIImage)
    public init(image: UIImage, averageColor: UIColor = .randomColor()) {
        self.init(image: Image(uiImage: image), averageColor: Color(uiColor: averageColor))
    }
    #endif
    
    public init(url: URL?, averageColor: Color = .randomColor(), size: CGSize? = nil) {
        self.kind = (url == nil) ? .empty : .url(url!)
        self.averageColor = averageColor
        self.size = size
    }
    
    public static func emptyPhoto() -> Photo {
        return Photo(kind: .empty, averageColor: .randomColor(), size: nil)
    }
}

public enum RandomColorFactory: @unchecked Sendable {

    public static nonisolated(unsafe) var isOn: Bool = true
    public static nonisolated(unsafe) var defaultColor = Color(r: 255, g: 149, b: 0)
    
    /// Generates a random pastel color
    /// - Returns: a UIColor
    public static func randomColor() -> Color {
        guard isOn else {
            return defaultColor
        }
        /// Source: https://twitter.com/manuelmaly/status/1523335860258705408
        return Color(
            hue: .random(in: 0.0...1.0),
            saturation: .random(in: 0.2...0.55),
            brightness: 0.9,
            opacity: 1
        )
    }
}

public extension Photo {
    
    var url: URL? {
        switch self.kind {
        case .empty:
            return nil
        case .image:
            return nil
        case .url(let url):
            return url
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

// For some reason `CGSize` isn't `Hashable`
#if canImport(Darwin)
extension CGSize: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
}
#endif

// This was generated with ChatGPT o4-mini-high, so take with a grain of salt
extension Image: @retroactive Hashable {
    public static func == (lhs: Image, rhs: Image) -> Bool {
        return Mirror(reflecting: lhs).children.elementsEqual(Mirror(reflecting: rhs).children) { (lChild, rChild) in
            if let lh = lChild.value as? AnyHashable, let rh = rChild.value as? AnyHashable {
                return lh == rh
            }
            return String(describing: lChild.value) == String(describing: rChild.value)
        }
    }

    public func hash(into hasher: inout Hasher) {
        for child in Mirror(reflecting: self).children {
            if let value = child.value as? AnyHashable {
                hasher.combine(value)
            } else {
                hasher.combine(String(describing: child.value))
            }
        }
    }
}

#if canImport(Darwin)
extension Photo: Equatable, Hashable, Sendable {}
extension Photo.Kind: Equatable, Hashable, Sendable {}
#else
extension Photo: Equatable, Hashable, @unchecked Sendable {}
extension Photo.Kind: Equatable, Hashable, @unchecked Sendable {}
#endif
