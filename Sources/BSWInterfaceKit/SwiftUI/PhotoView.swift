//
//  Created by Michele Restuccia on 20/6/22.
//

import SwiftUI
import NukeUI

public struct PhotoView: View {
    
    public init(photo: Photo, configuration: PhotoView.Configuration = .init(placeholder: .init(shape: .rectangle))) {
        self.photo = photo
        self.configuration = configuration
    }
    
    let photo: Photo
    let configuration: Configuration
    @Environment(\.redactionReasons) var reasons: RedactionReasons
    
    public var body: some View {
        Group {
            if reasons.isEmpty {
                photoView
            } else {
                placeholder
            }
        }
        .aspectRatio(configuration.aspectRatio, contentMode: configuration.contentMode)
    }
    
    @ViewBuilder
    @MainActor
    private var placeholder: some View {
        configuration.placeholder
    }
    
    @ViewBuilder
    @MainActor
    private var photoView: some View {
        switch photo.kind {
        case .url(let url, _):
            LazyImage(url: url) { state in
                if let image = state.image {
                    image
                } else {
                    placeholder
                }
            }
            .animation(.default)
        case .image(let image):
            Image(uiImage: image)
                .resizable()
        default:
            placeholder
        }
    }
}

extension PhotoView {
        
    public struct Configuration {
        let placeholder: Placeholder
        let aspectRatio: CGFloat?
        let contentMode: ContentMode
        
        public init(placeholder: Placeholder, aspectRatio: CGFloat? = nil, contentMode: ContentMode = .fit) {
            self.placeholder = placeholder
            self.aspectRatio = aspectRatio
            self.contentMode = contentMode
        }
        
        public struct Placeholder: View {
            
            public init(shape: PhotoView.Configuration.Placeholder.Shape, color: Color = Color(RandomColorFactory.defaultColor)) {
                self.shape = shape
                self.color = color
            }
            
            let shape: Shape
            let color: Color
            
            public enum Shape {
                case circle, rectangle
            }
            
            public var body: some View {
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
