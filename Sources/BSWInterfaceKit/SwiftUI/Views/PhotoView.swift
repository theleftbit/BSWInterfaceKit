//
//  Created by Michele Restuccia on 20/6/22.
//

#if os(Android)
import SkipFuseUI
#else
import SwiftUI
#endif
#if canImport(Nuke)
import NukeUI; import Nuke
#endif

#if canImport(Darwin)
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
#endif

/// Displays a `Photo` in `SwiftUI`
public struct PhotoView: View {
    
    public init(photo: Photo, configuration: PhotoView.Configuration = .init()) {
        self.photo = photo
        self.configuration = configuration
    }
    
    let photo: Photo
    let configuration: Configuration
    
    public var body: some View {
        contentView
            .applyPhotoLayout(
                aspectRatio: configuration.aspectRatio,
                contentMode: configuration.contentMode
            )
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
        if isRunningTests || isPlaceholder {
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
    private var photoView: some View {
        switch photo.kind {
        case .url(let url):
            #if os(Android)
            androidPhotoView(url)
            #else
            iOSPhotoView(url)
            #endif
        case .image(let image):
            #if os(Android)
            image.photoStyle()
            #else
            image.resizable()
            #endif
        default:
            placeholder
        }
    }
    
    @ViewBuilder
    private func iOSPhotoView(_ url: URL) -> some View {
        #if canImport(Nuke)
        nukePhotoView(url: url)
        #else
        AsyncImage(url: url)
        #endif
    }
    
    #if os(Android)
    @ViewBuilder
    private func androidPhotoView(_ url: URL) -> some View {
        #if canImport(Nuke)
        nukePhotoView(url: url)
        #else
        basicAsyncImage(url: url)
        #endif
    }
    #endif
    
    var isRunningTests: Bool {
        #if canImport(UIKit.UIApplication)
        UIApplication.shared.isRunningTests
        #else
        false
        #endif
    }
    
    #if canImport(Nuke)
    @ViewBuilder
    func nukePhotoView(url: URL) -> some View {
        LazyImage(url: url, transaction: .init(animation: .default)) { state in
            #if canImport(UIKit)
            if configuration.shouldRemoveBackground, let uiImage = state.imageContainer?.image {
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
    }
    #endif
    
    #if os(Android)
    @ViewBuilder
    private func basicAsyncImage(url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image.photoStyle()
            case .failure(_):
                configuration.placeholder.body()
            default:
                configuration.placeholder.body()
            }
        }
    }
    #endif
    
    #if canImport(Darwin)
    @Environment(\.redactionReasons) var reasons
    
    var isPlaceholder: Bool {
        reasons.contains(.placeholder)
    }
    #else
    var isPlaceholder: Bool {
        false
    }
    #endif
    
}

extension PhotoView {
        
    public struct Configuration {
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
        
        public struct Placeholder {
            
            public init(shape: PhotoView.Configuration.Placeholder.Shape, color: Color = RandomColorFactory.defaultColor) {
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

extension PhotoView.Configuration: Sendable {}
extension PhotoView.Configuration.Placeholder: Sendable {}
extension PhotoView.Configuration.Placeholder.Shape: Sendable {}

#if os(Android)
private extension Image {
    func photoStyle() -> some View {
        self
            .resizable()
            .interpolation(.high)
            .antialiased(true)
    }
}
#endif

private extension View {
    @ViewBuilder
    func applyPhotoLayout(aspectRatio: CGFloat?, contentMode: ContentMode) -> some View {
        #if os(Android)
        if let ratio = aspectRatio {
            self.aspectRatio(ratio, contentMode: contentMode)
        } else {
            switch contentMode {
            case .fit:
                self.scaledToFit()
            case .fill:
                self.scaledToFill().clipped()
            @unknown default:
                self.scaledToFit()
            }
        }
        #else
        self.aspectRatio(aspectRatio, contentMode: contentMode)
        #endif
    }
}

#if canImport(UIKit)

private extension PhotoView {
    
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

private extension UIImage {
    
    #if targetEnvironment(simulator)
    nonisolated func extractSubject() async -> UIImage? {
        self
    }
    #else
    nonisolated func extractSubject() async -> UIImage {
        guard let inputImage = CIImage(image: self) else { return self }
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(ciImage: inputImage)
        
        do {
            try handler.perform([request])
            guard let result = request.results?.first,
                  let mask = try? result.generateScaledMaskForImage(
                    forInstances: result.allInstances,
                    from: handler
                  ) else {
                return self
            }
            let maskImage = CIImage(cvPixelBuffer: mask)
            let filter = CIFilter.blendWithMask()
            filter.inputImage = inputImage
            filter.maskImage = maskImage
            filter.backgroundImage = CIImage.empty()
            
            guard let outputImage = filter.outputImage,
                  let cgImage = CIContext(options: nil).createCGImage(outputImage, from: outputImage.extent)
            else { return self }
            
            return UIImage(cgImage: cgImage)
        } catch {
            return self
        }
    }
    #endif
}
#endif
