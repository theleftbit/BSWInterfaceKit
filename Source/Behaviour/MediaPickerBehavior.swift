//
//  Created by Pierluigi Cifani on 08/08/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

public typealias MediaHandler = ((URL?) -> Void)

final public class MediaPickerBehavior: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public enum Kind {
        case photo
        case video
        
        func toUIKit() -> UIImagePickerControllerCameraCaptureMode {
            switch self {
            case .photo:
                return .photo
            case .video:
                return .video
            }
        }
        
        func pathExtension() -> String {
            switch self {
            case .photo:
                return "png"
            case .video:
                return "mov"
            }
        }
    }
    
    public enum Source {
        case photoAlbum
        case camera
        
        func toUIKit() -> UIImagePickerControllerSourceType {
            switch self {
            case .camera:
                return .camera
            case .photoAlbum:
                return .photoLibrary
            }
        }
    }

    fileprivate struct Request {
        let handler: MediaHandler
        let kind: Kind
    }
    
    fileprivate weak var presentingVC: UIViewController?
    fileprivate var currentRequest: Request?
    fileprivate let imagePicker = UIImagePickerController()

    public init(presentingVC: UIViewController) {
        self.presentingVC = presentingVC
        super.init()
    }
 
    public func getMedia(_ kind: Kind = .photo, source: Source = .photoAlbum, handler: @escaping MediaHandler) {
        
        guard self.currentRequest == nil else {
            handler(nil)
            return
        }
        
        guard UIImagePickerController.isSourceTypeAvailable(source.toUIKit()) else {
            handler(nil)
            return
        }

        self.currentRequest = Request(handler: handler, kind: kind)
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = source.toUIKit()
        imagePicker.delegate = self
        switch kind {
        case .video:
            imagePicker.mediaTypes = [kUTTypeMovie as String]
        case .photo:
            imagePicker.mediaTypes = [kUTTypeImage as String]
        }
        
        presentingVC?.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            self.currentRequest = nil
            picker.dismiss(animated: true, completion: nil)
        }
        
        guard let currentRequest = self.currentRequest else { return }
        
        let validMedia: Bool = {
            guard let mediaTypeString = info[UIImagePickerControllerMediaType] as? String else { return false }
            switch currentRequest.kind {
            case .video:
                return mediaTypeString == kUTTypeMovie as String
            case .photo:
                return mediaTypeString == kUTTypeImage as String
            }
        }()
        
        guard validMedia else {
            self.currentRequest?.handler(nil)
            return
        }
        
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            self.currentRequest?.handler(nil)
            return
        }

        guard let data = UIImageJPEGRepresentation(image, 0.6) else {
            self.currentRequest?.handler(nil)
            return
        }
        
        do {
            let finalURL = cachePathForMedia(currentRequest.kind)
            try data.write(to: finalURL, options: [.atomic])
            self.currentRequest?.handler(finalURL)
        } catch {
            self.currentRequest?.handler(nil)
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentRequest?.handler(nil)
        currentRequest = nil
    }
    
    fileprivate func cachePathForMedia(_ kind: Kind) -> URL {
        let fileManager = FileManager.default
        let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cachesDirectory.appendingPathComponent("\(UUID().uuidString).\(kind.pathExtension())")
    }
}
