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
            .aspectRatio(
                configuration.aspectRatio,
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
            androidPhotoView(url: url)
            #else
            #if canImport(Nuke)
            nukePhotoView(url: url)
            #else
            AsyncImage(url: url)
            #endif
            #endif
        case .image(let image):
            #if os(Android)
            image.photoStyle()
            #else
            image
                .resizable()
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
    
    // MARK: - Android

    #if os(Android)
    @ViewBuilder
    private func androidPhotoView(url: URL) -> some View {
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

    // MARK: - iOS

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

// MARK: - Android image styling

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

private enum SubjectMaskConfig {
    static let minRelativeWidth: CGFloat = 0.75
    static let minRelativeHeight: CGFloat = 0.75
    static let growRadius: Float = 2
    static let featherRadius: Float = 1
    static let sampleSize = 64
    static let maskThreshold: UInt8 = 32
    static let whiteThreshold: UInt8 = 235
    static let neutralTolerance: UInt8 = 22
}

private extension UIImage {
    
    static let ciContext = CIContext(options: nil)
    
    #if targetEnvironment(simulator)
    nonisolated func extractSubject() async -> UIImage {
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
                .applyingFilter("CIMorphologyMaximum", parameters: [
                    kCIInputRadiusKey: SubjectMaskConfig.growRadius
                ])
                .applyingFilter("CIGaussianBlur", parameters: [
                    kCIInputRadiusKey: SubjectMaskConfig.featherRadius
                ])
                .cropped(to: inputImage.extent)
            
            guard Self.matchesProductBounds(maskImage, in: inputImage, extent: inputImage.extent) else {
                return self
            }
            
            let filter = CIFilter.blendWithMask()
            filter.inputImage = inputImage
            filter.maskImage = maskImage
            filter.backgroundImage = CIImage(color: .clear).cropped(to: inputImage.extent)
            
            guard let outputImage = filter.outputImage,
                  let cgImage = Self.ciContext.createCGImage(outputImage, from: inputImage.extent)
            else { return self }
            
            return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
        } catch {
            return self
        }
    }
    
    nonisolated private static func matchesProductBounds(
        _ maskImage: CIImage,
        in inputImage: CIImage,
        extent: CGRect
    ) -> Bool {
        guard let maskBounds = bounds(for: maskImage, extent: extent, isMask: true),
              let contentBounds = bounds(for: inputImage, extent: extent, isMask: false)
        else {
            return false
        }
        
        return maskBounds.width >= contentBounds.width * SubjectMaskConfig.minRelativeWidth &&
            maskBounds.height >= contentBounds.height * SubjectMaskConfig.minRelativeHeight
    }
    
    nonisolated private static func bounds(
        for image: CIImage,
        extent: CGRect,
        isMask: Bool
    ) -> CGRect? {
        guard extent.width > 0, extent.height > 0 else { return nil }
        
        let sampleSize = SubjectMaskConfig.sampleSize
        let sampleDimension = CGFloat(sampleSize)
        let scaledImage = image
            .transformed(by: CGAffineTransform(
                scaleX: sampleDimension / extent.width,
                y: sampleDimension / extent.height
            ))
            .cropped(to: CGRect(x: 0, y: 0, width: sampleDimension, height: sampleDimension))
        
        var pixels = [UInt8](repeating: 0, count: sampleSize * sampleSize * 4)
        ciContext.render(
            scaledImage,
            toBitmap: &pixels,
            rowBytes: sampleSize * 4,
            bounds: CGRect(x: 0, y: 0, width: sampleDimension, height: sampleDimension),
            format: .RGBA8,
            colorSpace: nil
        )
        
        var minX = sampleSize
        var minY = sampleSize
        var maxX = -1
        var maxY = -1
        
        for y in 0..<sampleSize {
            for x in 0..<sampleSize {
                let index = ((y * sampleSize) + x) * 4
                let red = pixels[index]
                let green = pixels[index + 1]
                let blue = pixels[index + 2]
                
                let isActive: Bool
                if isMask {
                    isActive = red >= SubjectMaskConfig.maskThreshold
                } else {
                    let minComponent = min(red, min(green, blue))
                    let maxComponent = max(red, max(green, blue))
                    isActive = !(minComponent >= SubjectMaskConfig.whiteThreshold &&
                        Int(maxComponent) - Int(minComponent) <= Int(SubjectMaskConfig.neutralTolerance))
                }
                
                guard isActive else { continue }
                
                minX = min(minX, x)
                minY = min(minY, y)
                maxX = max(maxX, x)
                maxY = max(maxY, y)
            }
        }
        
        guard maxX >= 0, maxY >= 0 else { return nil }
        
        return CGRect(
            x: CGFloat(minX) / sampleDimension,
            y: CGFloat(minY) / sampleDimension,
            width: CGFloat(maxX - minX + 1) / sampleDimension,
            height: CGFloat(maxY - minY + 1) / sampleDimension
        )
    }
    #endif
}
#endif
