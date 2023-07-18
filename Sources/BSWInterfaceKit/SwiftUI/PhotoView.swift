//
//  Created by Michele Restuccia on 20/6/22.
//

import SwiftUI
import NukeUI

/// Displays a `Photo` in `SwiftUI`
public struct PhotoView: View {
    
    public init(photo: Photo, placeholder: Placeholder? = nil) {
        self.photo = photo
        self.placeholder = placeholder ?? .init(shape: .rectangle, color: .init(uiColor: .systemGray2))
    }
    
    let photo: Photo
    let placeholder: Placeholder
    @Environment(\.redactionReasons) var reasons: RedactionReasons
    
    public var body: some View {
        if shouldShowPlaceholder {
            placeholder
        } else {
            UIImageViewWrapper(photo: photo)
        }
    }
    
    private var shouldShowPlaceholder: Bool {
        if UIApplication.shared.isRunningTests {
            return true
        } else if reasons.isEmpty == false {
            return true
        } else {
            return false
        }
    }
}

extension PhotoView {
    
    public struct Placeholder: View {
        
        public init(shape: PhotoView.Placeholder.Shape = .rectangle, color: Color = Color(RandomColorFactory.defaultColor)) {
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
            .foregroundStyle(color)
        }
    }
}

private struct UIImageViewWrapper: UIViewRepresentable {
        
    let photo: Photo

    public func makeUIView(context: Context) -> UIImageView {
        let uiView = UIImageView()
        uiView.setPhoto(photo)
        uiView.setContentHuggingPriority(.defaultLow, for: .vertical)
        uiView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        uiView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        uiView.clipsToBounds = true
        return uiView
    }

    public func updateUIView(_ uiView: UIImageView, context: Context) {

    }
}
