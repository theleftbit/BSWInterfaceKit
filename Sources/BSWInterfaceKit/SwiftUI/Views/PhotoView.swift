//
//  Created by Michele Restuccia on 20/6/22.
//

import SwiftUI
import NukeUI

/// Displays a `Photo` in `SwiftUI`
public struct PhotoView: View {
    
    public init(photo: Photo, configuration: PhotoView.Configuration = .init()) {
        self.photo = photo
        self.configuration = configuration
    }
    
    let photo: Photo
    let configuration: Configuration
    @Environment(\.redactionReasons) var reasons: RedactionReasons
    
    public var body: some View {
        Group {
            if shouldShowPlaceholder {
                placeholder
            } else {
                photoView
            }
        }
        .aspectRatio(configuration.aspectRatio, contentMode: configuration.contentMode)
    }
    
    private var shouldShowPlaceholder: Bool {
        if isRunningTests {
            return true
        } else if reasons.isEmpty == false {
            return true
        } else {
            return false
        }
    }
    
    @ViewBuilder
    private var placeholder: some View {
        configuration.placeholder.body()
    }
    
    @ViewBuilder
    @MainActor
    private var photoView: some View {
        switch photo.kind {
        case .url(let url, _):
            LazyImage(url: url, transaction: .init(animation: .default)) { state in
                if let image = state.image {
                    image
                        .resizable()
                } else {
                    placeholder
                }
            }
        case .image(let image):
            #if canImport(UIKit)
            Image(uiImage: image)
                .resizable()
            #elseif canImport(AppKit)
            Image(nsImage: image)
            #endif
        default:
            placeholder
        }
    }
    
    var isRunningTests: Bool {
        #if canImport(UIKit.UIApplication)
        UIApplication.shared.isRunningTests
        #else
        false
        #endif
    }
}

extension PhotoView {
        
    public struct Configuration {
        let placeholder: Placeholder
        let aspectRatio: CGFloat?
        let contentMode: ContentMode
        
        public init(placeholder: Placeholder = .init(shape: .rectangle), aspectRatio: CGFloat? = nil, contentMode: ContentMode = .fit) {
            self.placeholder = placeholder
            self.aspectRatio = aspectRatio
            self.contentMode = contentMode
        }
        
        public struct Placeholder {
            
            public init(shape: PhotoView.Configuration.Placeholder.Shape, color: Color = Color(RandomColorFactory.defaultColor)) {
                self.shape = shape
                self.color = color
            }
            
            let shape: Shape
            let color: Color
            
            public enum Shape {
                case circle, rectangle
            }
            
            func body() -> some View {
                Group {
                    switch self.shape {
                    case .circle:
                        Circle()
                    case .rectangle:
                        Rectangle()
                    }
                }
                .foregroundColor(color)
            }
        }
    }
}
