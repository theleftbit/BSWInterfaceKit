//
//  Created by Pierluigi Cifani on 08/08/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import MobileCoreServices
import ImageIO
import AVFoundation
import Photos
import UniformTypeIdentifiers
import PhotosUI

public typealias MediaHandler = ((URL?) -> Void)

@available(tvOS, unavailable)
final public class MediaPickerBehavior: NSObject, UIDocumentPickerDelegate, PHPickerViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public enum Kind {
        case photo
        case video
        case thumbnail(CGSize)
        
        func pathExtension() -> String {
            switch self {
            case .photo, .thumbnail:
                return "jpeg"
            case .video:
                return "mov"
            }
        }
        
        var contentTypes: [UTType] {
            switch self {
            case .photo, .thumbnail:
                return [UTType.image, UTType.jpeg, UTType.png]
            case .video:
                return [UTType.movie, UTType.video, UTType.quickTimeMovie]
            }
        }
    }
    
    public enum Source {
        case photoAlbum
        case camera
        case filesApp
    }

    private struct Request {
        let kind: Kind
        let fromVC: UIViewController
        let cont: CheckedContinuation<URL?, Never>
    }
    
    private var currentRequest: Request?
    private let fileManager = FileManager.default
 
    public func getMedia(fromVC: UIViewController, kind: Kind = .photo, source: Source = .photoAlbum) async -> URL? {
        
        guard self.currentRequest == nil else {
            return nil
        }
        
        let vc: UIViewController? = {
            switch source {
            case .filesApp:
                return handleFilesAppRequest(kind: kind)
            case .camera:
                return handleCameraRequest(kind: kind)
            case .photoAlbum:
                return handlePhotoPickerRequest(kind: kind)
            }
        }()
        guard let vc = vc else { return nil }
        fromVC.present(vc, animated: true)
        return await withCheckedContinuation { cont in
            self.currentRequest = Request(kind: kind, fromVC: fromVC, cont: cont)
        }
    }
    
    @available(iOS 15, *)
    public func createVideoThumbnail(forURL videoURL: URL) async throws -> URL {
        let asset = AVAsset(url: videoURL)
        let durationSeconds = CMTimeGetSeconds(asset.duration)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTimeMakeWithSeconds(durationSeconds/3.0, preferredTimescale: 600)
        return try await withCheckedThrowingContinuation { continuation in
            generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { (_, thumbnail, _, _, error) in
                guard let thumbnail = thumbnail else {
                    continuation.resume(throwing: Error.unknown)
                    return
                }
                guard error == nil else {
                    continuation.resume(throwing: error!)
                    return
                }
                
                let image = UIImage(cgImage: thumbnail)
                let preferredAspectRatio = image.size.width / image.size.height
                image.prepareThumbnail(of: .init(width: 500, height: 500/preferredAspectRatio)) { thumbnailImage in
                    do {
                        let finalImage = thumbnailImage ?? image
                        let finalURL = try self.writeToCache(image: finalImage, kind: .photo)
                        continuation.resume(returning: finalURL)
                    } catch let error {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    // MARK: UIDocumentPickerDelegate
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        defer {
            self.currentRequest = nil
        }
        guard let currentRequest = self.currentRequest, let url = urls.first else { return }
        let targetURL = cachePathForMedia(currentRequest.kind)
        do {
            try self.fileManager.moveItem(at: url, to: targetURL)
            self.finishRequest(withURL: targetURL, shouldDismissVC: false)
        } catch {
            self.finishRequest(withURL: nil, shouldDismissVC: false)
        }
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        self.finishRequest(withURL: nil, shouldDismissVC: false)
    }

    // MARK: UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let currentRequest = self.currentRequest else { return }
        
        defer {
            self.currentRequest = nil
        }
        
        let validMedia: Bool = {
            guard let mediaTypeString = info[.mediaType] as? String else { return false }
            switch currentRequest.kind {
            case .video:
                return mediaTypeString == kUTTypeMovie as String
            case .photo, .thumbnail:
                return mediaTypeString == kUTTypeImage as String
            }
        }()
        
        guard validMedia else {
            self.finishRequest(withURL: nil)
            return
        }
        
        switch currentRequest.kind {
        case .video:
            handleVideoRequest(info: info, request: currentRequest)
        case .photo:
            handlePhotoRequest(info: info, request: currentRequest)
        case .thumbnail:
            handleThumbnailRequest(info: info, request: currentRequest)
        }
    }
        
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.finishRequest(withURL: nil)
    }

    // MARK: PHPickerViewControllerDelegate
    
    public func picker(_ p: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let currentRequest = self.currentRequest else { return }
        guard let itemProvider = results.first?.itemProvider, let contentType = currentRequest.kind.contentTypes.first else {
            self.finishRequest(withURL: nil)
            return
        }
        let progress = itemProvider.loadFileRepresentation(forTypeIdentifier: contentType.identifier) { url, _ in
            guard let url = url else {
                self.finishRequest(withURL: nil)
                return
            }
            let targetURL = self.cachePathForMedia(currentRequest.kind)
            let didSucceed: Bool = {
                do {
                    try self.fileManager.moveItem(at: url, to: targetURL)
                    return true
                } catch {
                    return false
                }
            }()
            self.finishRequest(withURL: didSucceed ? targetURL : nil)
        }
        let vc = TranscodeProgressView(progress: progress).asViewController()
        if #available(iOS 15.0, *) {
            vc.sheetPresentationController?.detents = [.medium()]
        }
        p.present(vc, animated: true)
    }
    
    // MARK: Private

    private func handleFilesAppRequest(kind: Kind) -> UIViewController? {
        let vc = UIDocumentPickerViewController(forOpeningContentTypes: kind.contentTypes, asCopy: true)
        vc.delegate = self
        vc.allowsMultipleSelection = false
        return vc
    }

    private func handleCameraRequest(kind: Kind) -> UIViewController? {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return nil
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.cameraDevice = .front
        switch kind {
        case .video:
            imagePicker.mediaTypes = [kUTTypeMovie as String]
        case .photo, .thumbnail:
            imagePicker.mediaTypes = [kUTTypeImage as String]
        }
        return imagePicker
    }
    
    private func handlePhotoPickerRequest(kind: Kind) -> UIViewController? {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        switch kind {
        case .photo:
            configuration.filter = .any(of: [.livePhotos, .images])
        case .thumbnail:
            configuration.filter = .images
        case .video:
            configuration.filter = .videos
        }
        let vc = PHPickerViewController(configuration: configuration)
        vc.delegate = self
        return vc
    }
    
    private func cachePathForMedia(_ kind: Kind) -> URL {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cachesDirectory.appendingPathComponent("\(UUID().uuidString).\(kind.pathExtension())")
    }
    
    private func handleVideoRequest(info: [UIImagePickerController.InfoKey : Any], request: Request) {
        if let videoURL = info[.mediaURL] as? URL {
            self.finishRequest(withURL: videoURL)
        } else if let asset = info[.phAsset] as? PHAsset {
            let options = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: {(asset, _, _) -> Void in
                Task {
                    if let urlAsset = asset as? AVURLAsset {
                        self.finishRequest(withURL: urlAsset.url)
                    } else {
                        self.finishRequest(withURL: nil)
                    }
                }
            })

        } else {
            self.finishRequest(withURL: nil)
        }
    }

    private func handlePhotoRequest(info: [UIImagePickerController.InfoKey : Any], request: Request) {
        
        guard let image = info[.originalImage] as? UIImage else {
            self.finishRequest(withURL: nil)
            return
        }
        
        do {
            let finalURL = try writeToCache(image: image, kind: request.kind)
            self.finishRequest(withURL: finalURL)
        } catch {
            self.finishRequest(withURL: nil)
        }
    }
    
    private func handleThumbnailRequest(info: [UIImagePickerController.InfoKey : Any], request: Request) {
        guard case .thumbnail(let size) = request.kind else {
            fatalError()
        }
        
        let _image: UIImage? = {
            var imageSource: CGImageSource!
            if let imageURL = info[.imageURL] as? URL {
                imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil)
            } else if let image = info[.originalImage] as? UIImage, let data = image.jpegData(compressionQuality: 1) {
                imageSource = CGImageSourceCreateWithData(data as CFData, nil)
            }
            
            if imageSource == nil {
                return nil
            }
            
            let _ = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil)
            let options: [NSString: Any] = [
                kCGImageSourceThumbnailMaxPixelSize: size.width,
                kCGImageSourceCreateThumbnailFromImageAlways: true,
                kCGImageSourceCreateThumbnailWithTransform: true
            ]
            
            guard let scaledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
                return nil
            }
            return UIImage(cgImage: scaledImage)
        }()
        
        guard let image = _image else {
            request.cont.resume(returning: nil)
            return
        }
        
        do {
            let url = try writeToCache(image: image, kind: request.kind)
            request.cont.resume(returning: url)
        } catch {
            request.cont.resume(returning: nil)
        }

    }
    
    private func writeToCache(image: UIImage, kind: Kind) throws -> URL {
        guard let data = image.jpegData(compressionQuality: 1) else {
            throw Error.jpegCompressionFailed
        }
        
        let finalURL = cachePathForMedia(kind)
        do {
            try data.write(to: finalURL, options: [.atomic])
            return finalURL
        }
        catch {
            throw Error.diskWriteFailed
        }
    }
    
    private func finishRequest(withURL url: URL?, shouldDismissVC: Bool = true) {
        guard let currentRequest = self.currentRequest  else { return }
        currentRequest.cont.resume(returning: url)
        if shouldDismissVC {
            let vc = currentRequest.fromVC
            DispatchQueue.main.async {
                vc.dismiss(animated: true)
            }
        }
        self.currentRequest = nil
    }

    enum Error: Swift.Error {
        case jpegCompressionFailed
        case diskWriteFailed
        case unknown
    }
}

import SwiftUI

private struct TranscodeProgressView: SwiftUI.View {
    let progress: Progress
    @State private var progressCount: Double = 0

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Preparing for upload:")
                    .font(.title2)
                Spacer()
            }
            ProgressView(value: progressCount, total: 1)
            Button {
                progress.cancel()
            } label: {
                Text("Cancel")
            }
        }
        .padding()
        .onReceive(progress.publisher(for: \.fractionCompleted).receive(on: RunLoop.main)) { value in
            withAnimation {
                progressCount = value
            }
        }
    }
}

#endif
