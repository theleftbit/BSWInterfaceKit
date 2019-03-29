//
//  Created by Pierluigi Cifani on 08/08/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit
import MobileCoreServices
import ImageIO
import AVFoundation
import Deferred
import Photos

public typealias MediaHandler = ((URL?) -> Void)

final public class MediaPickerBehavior: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public enum Kind {
        case photo
        case video
        
        @available(iOS 11, *)
        case thumbnail(CGSize)

        func toUIKit() -> UIImagePickerController.CameraCaptureMode {
            switch self {
            case .photo, .thumbnail:
                return .photo
            case .video:
                return .video
            }
        }
        
        func pathExtension() -> String {
            switch self {
            case .photo, .thumbnail:
                return "jpeg"
            case .video:
                return "mov"
            }
        }
    }
    
    public enum Source {
        case photoAlbum
        case camera
        
        func toUIKit() -> UIImagePickerController.SourceType {
            switch self {
            case .camera:
                return .camera
            case .photoAlbum:
                return .photoLibrary
            }
        }
    }

    private struct Request {
        let handler: MediaHandler
        let kind: Kind
    }
    
    private var currentRequest: Request?
    private let imagePicker = UIImagePickerController()
    private let fileManager = FileManager.default
 
    public func getMedia(_ kind: Kind = .photo, source: Source = .photoAlbum) -> (UIViewController?, Task<URL>) {
        let deferred = Deferred<Task<URL>.Result>()
        let vc = getMedia(kind, source: source) { (url) in
            if let url = url {
                deferred.fill(with: .success(url))
            } else {
                deferred.fill(with: .failure(Error.unknown))
            }
        }
        return (vc, Task(deferred))
    }
    
    public func getMedia(_ kind: Kind = .photo, source: Source = .photoAlbum, handler: @escaping MediaHandler) -> UIViewController? {
        
        guard self.currentRequest == nil else {
            handler(nil)
            return nil
        }
        
        guard UIImagePickerController.isSourceTypeAvailable(source.toUIKit()) else {
            handler(nil)
            return nil
        }

        self.currentRequest = Request(handler: handler, kind: kind)
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = source.toUIKit()
        if source == .camera {
            imagePicker.cameraDevice = .front
        }
        imagePicker.delegate = self
        switch kind {
        case .video:
            imagePicker.mediaTypes = [kUTTypeMovie as String]
        case .photo, .thumbnail:
            imagePicker.mediaTypes = [kUTTypeImage as String]
        }
        
        return imagePicker
    }
    
    public func createVideoThumbnail(forURL videoURL: URL) -> Task<URL> {
        let deferred = Deferred<Task<URL>.Result>()

        let asset = AVAsset(url: videoURL)
        let durationSeconds = CMTimeGetSeconds(asset.duration)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let time = CMTimeMakeWithSeconds(durationSeconds/3.0, preferredTimescale: 600)
        generator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { (_, thumbnail, _, _, _) in
            guard let thumbnail = thumbnail else {
                return
            }
            let image = UIImage(cgImage: thumbnail)
            do {
                let finalURL = try self.writeToCache(image: image, kind: .photo)
                deferred.fill(with: .success(finalURL))
            } catch let error {
                deferred.fill(with: .failure(error))
            }
        }
        
        return Task(deferred)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        defer {
            self.currentRequest = nil
        }
        
        guard let currentRequest = self.currentRequest else { return }
        
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
            self.currentRequest?.handler(nil)
            return
        }
        
        switch currentRequest.kind {
        case .video:
            handleVideoRequest(info: info, request: currentRequest)
        case .photo:
            handlePhotoRequest(info: info, request: currentRequest)
        case .thumbnail:
            if #available(iOS 11.0, *) {
                handleThumbnailRequest(info: info, request: currentRequest)
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentRequest?.handler(nil)
        currentRequest = nil
    }
    
    private func cachePathForMedia(_ kind: Kind) -> URL {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cachesDirectory.appendingPathComponent("\(UUID().uuidString).\(kind.pathExtension())")
    }
    
    private func handleVideoRequest(info: [UIImagePickerController.InfoKey : Any], request: Request) {
        if let videoURL = info[.mediaURL] as? URL {
            request.handler(videoURL)
        } else if let asset = info[.phAsset] as? PHAsset {
            let options = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options, resultHandler: {(asset, _, _) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    request.handler(urlAsset.url)
                } else {
                    request.handler(nil)
                }
            })

        } else {
            request.handler(nil)
        }
    }

    private func handlePhotoRequest(info: [UIImagePickerController.InfoKey : Any], request: Request) {
        
        guard let image = info[.originalImage] as? UIImage else {
            self.currentRequest?.handler(nil)
            return
        }
        
        do {
            let finalURL = try writeToCache(image: image, kind: request.kind)
            self.currentRequest?.handler(finalURL)
        } catch {
            self.currentRequest?.handler(nil)
        }
    }
    
    @available(iOS 11.0, *)
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
            request.handler(nil)
            return
        }
        
        do {
            let url = try writeToCache(image: image, kind: request.kind)
            request.handler(url)
        } catch {
            request.handler(nil)
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
    
    enum Error: Swift.Error {
        case jpegCompressionFailed
        case diskWriteFailed
        case unknown
    }
}
