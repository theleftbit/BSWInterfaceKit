//
//  Created by Michele Restuccia on 11/7/22.
//

#if canImport(UIKit)

import UIKit
import PhotosUI

final public class MediaPickerBehaviorV2: NSObject, PHPickerViewControllerDelegate, UIDocumentPickerDelegate {
    
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
        
        var imagePickerSource: UIImagePickerController.SourceType {
            switch self {
            case .camera:
                return .camera
            case .photoAlbum:
                return .photoLibrary
            case .filesApp:
                fatalError()
            }
        }
    }

    private struct Request {
        let handler: MediaHandler
        let kind: Kind
    }
    
    private var currentRequest: Request?
    private let configuration = PHPickerConfiguration()
    private var pickerViewController: PHPickerViewController!
    private let fileManager = FileManager.default
    
    public func getMedia(_ kind: Kind = .photo, source: Source = .photoAlbum, handler: @escaping MediaHandler) -> UIViewController? {
        guard self.currentRequest == nil else {
            handler(nil)
            return nil
        }
        
        switch source {
        case .filesApp:
            return handleRequestWithFilesApp(kind: kind, source: source, handler: handler)
        case .camera, .photoAlbum:
            return handleRequestWithImagePicker(kind: kind, source: source, handler: handler)
        }
    }
    
    //MARK: PHPickerViewControllerDelegate
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        guard let currentRequest = self.currentRequest else { return }
        
        defer {
            self.currentRequest = nil
        }
                
        switch currentRequest.kind {
        case .video:
            #warning("todo")
        case .photo:
            handlePhotoRequest(results: results, request: currentRequest)
        case .thumbnail:
            #warning("todo")
        }
    }
    
    // MARK: UIDocumentPickerDelegate
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        defer {
            self.currentRequest = nil
        }
        guard let currentRequest = self.currentRequest, let url = urls.first else { return }
        currentRequest.handler(url)
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        currentRequest?.handler(nil)
        currentRequest = nil
    }
}

private extension MediaPickerBehaviorV2 {
    
    func handleRequestWithFilesApp(kind: Kind, source: Source, handler: @escaping MediaHandler) -> UIViewController? {
        let vc = UIDocumentPickerViewController(forOpeningContentTypes: kind.contentTypes, asCopy: true)
        vc.delegate = self
        vc.allowsMultipleSelection = false
        self.currentRequest = Request(handler: handler, kind: kind)
        return vc
    }
    
    func handleRequestWithImagePicker(kind: Kind, source: Source, handler: @escaping MediaHandler) -> UIViewController? {
        self.currentRequest = Request(handler: handler, kind: kind)
        self.pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = self
        return pickerViewController
    }
    
    private func handlePhotoRequest(results: [PHPickerResult], request: Request) {
        let itemProviders = results.map(\.itemProvider)
        itemProviders.forEach { provider in
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { (image, error) in
                    print(error)
                    if let image = image as? UIImage {
                        do {
                            let finalURL = try self.writeToCache(image: image, kind: request.kind)
                            self.currentRequest?.handler(finalURL)
                        } catch {
                            self.currentRequest?.handler(nil)
                        }
                    }
                }
            } else {
                self.currentRequest?.handler(nil)
            }
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
    
    private func cachePathForMedia(_ kind: Kind) -> URL {
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cachesDirectory.appendingPathComponent("\(UUID().uuidString).\(kind.pathExtension())")
    }
    
    enum Error: Swift.Error {
        case jpegCompressionFailed
        case diskWriteFailed
        case unknown
    }
}

#endif
