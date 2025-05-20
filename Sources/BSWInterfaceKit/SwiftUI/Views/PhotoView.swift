//
//  Created by Michele Restuccia on 20/6/22.
//

import SwiftUI
import NukeUI; import Nuke

#Preview {
    PhotoView(
        photo: .init(url: URL(string: "https://static.nike.com/a/images/t_PDP_1728_v1/f_auto,q_auto:eco/b7d9211c-26e7-431a-ac24-b0540fb3c00f/AIR+FORCE+1+%2707.png")),
        configuration: .init(
            placeholder: .init(shape: .rectangle),
            aspectRatio: nil,
            contentMode: .fit,
            shouldRemoveBackground: false
        )
    )
    .frame(width: 300)
    .border(Color.red)
}

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
        contentView
            .aspectRatio(configuration.aspectRatio, contentMode: configuration.contentMode)
    }
    
    @ViewBuilder
    private var contentView: some View {
        if shouldShowPlaceholder {
            placeholder
        } else {
            photoView
        }
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
        case .url(let url):
            LazyImage(url: url, transaction: .init(animation: .default)) { state in
                #if canImport(UIKit)
                if #available(iOS 17.0, *), configuration.shouldRemoveBackground, let uiImage = state.imageContainer?.image {
                    RemoveBackgroundView(image: uiImage, placeholder: configuration.placeholder)
                } else if let image = state.image {
                    image
                        .resizable()
                } else {
                    placeholder
                }
                #else
                if let image = state.image {
                    image
                        .resizable()
                } else {
                    placeholder
                }
                #endif
            }
        case .image(let image):
            image
                .resizable()
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
        
    public struct Configuration: Sendable {
        let placeholder: Placeholder
        let aspectRatio: CGFloat?
        let contentMode: ContentMode
        let shouldRemoveBackground: Bool
        
        public init(placeholder: Placeholder = .init(shape: .rectangle), aspectRatio: CGFloat? = nil, contentMode: ContentMode = .fit, shouldRemoveBackground: Bool = false) {
            self.placeholder = placeholder
            self.aspectRatio = aspectRatio
            self.contentMode = contentMode
            self.shouldRemoveBackground = shouldRemoveBackground
        }
        
        public struct Placeholder: Sendable {
            
            public init(shape: PhotoView.Configuration.Placeholder.Shape, color: Color = RandomColorFactory.defaultColor) {
                self.shape = shape
                self.color = color
            }
            
            let shape: Shape
            let color: Color
            
            public enum Shape: Sendable {
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

#if canImport(UIKit)

private extension PhotoView {
    
    @available(iOS 17, *)
    struct RemoveBackgroundView: View {
        
        let image: UIImage
        let placeholder: PhotoView.Configuration.Placeholder
        
        @State var decodedImage: UIImage?
        
        var body: some View {
            Group {
                if let decodedImage {
                    Image(uiImage: decodedImage)
                        .resizable()
                } else {
                    placeholder.body()
                }
            }
            .task {
                self.decodedImage = await image.extractSubject()
            }
        }
    }
}

import Vision
import CoreImage
import CoreImage.CIFilterBuiltins

@available(iOS 17.0, *)
private extension UIImage {
    
    #if targetEnvironment(simulator)
    nonisolated func extractSubject() async -> UIImage? {
        self
    }
    #else
    nonisolated func extractSubject() async -> UIImage? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(ciImage: inputImage)
        
        do {
            try handler.perform([request])
            guard let result = request.results?.first,
                  let mask = try? result.generateScaledMaskForImage(
                    forInstances: result.allInstances,
                    from: handler
                  ) else {
                return nil
            }
            let maskImage = CIImage(cvPixelBuffer: mask)
            let filter = CIFilter.blendWithMask()
            filter.inputImage = inputImage
            filter.maskImage = maskImage
            filter.backgroundImage = CIImage.empty()
            
            guard let outputImage = filter.outputImage,
                  let cgImage = CIContext(options: nil).createCGImage(outputImage, from: outputImage.extent)
            else { return nil }
            
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
    #endif
}
#endif
