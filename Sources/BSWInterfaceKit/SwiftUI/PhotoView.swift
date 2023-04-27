//
//  Created by Michele Restuccia on 20/6/22.
//

import SwiftUI
import NukeUI

public struct PhotoView: View {
    
    let configuration: Configuration
    
    public init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    public var body: some View {
        Group {
            switch configuration.photo.kind {
            case .url(let url, _):
                LazyImage(url: url) { state in
                    if let image = state.image {
                        image
                    } else {
                        configuration.placeholderShape.body
                            .foregroundColor(Color(.systemGray3))
                    }
                }
                .animation(.default)
            case .image(let image):
                Image(uiImage: image)
                    .resizable()
            default:
                configuration.placeholderShape.body
                    .foregroundColor(defaultColor)
            }
        
        }
        .aspectRatio(configuration.aspectRatio, contentMode: configuration.contentMode)
    }
}

extension PhotoView {
    
    private var defaultColor: Color {
        Color(RandomColorFactory.defaultColor)
    }
    
    public struct Configuration {
        let photo: Photo
        let placeholderShape: PlaceholderShape
        let aspectRatio: CGFloat?
        let contentMode: ContentMode
        
        public init(photo: Photo, placeholderShape: PlaceholderShape, aspectRatio: CGFloat? = nil, contentMode: ContentMode = .fit) {
            self.photo = photo
            self.placeholderShape = placeholderShape
            self.aspectRatio = aspectRatio
            self.contentMode = contentMode
        }
        
        public enum PlaceholderShape: View {
            
            case circle, rectangle
            
            public var body: some View {
                Group {
                    switch self {
                    case .circle:
                        Circle()
                    case .rectangle:
                        Rectangle()
                    }
                }
            }
        }
    }
}
