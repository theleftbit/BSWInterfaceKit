//
//  Created by Pierluigi Cifani on 08/08/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos

public typealias MediaHandler = (NSURL? -> Void)

final public class MediaPickerBehavior: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    public enum Kind {
        case Photo
        case Video
        
        func toUIKit() -> UIImagePickerControllerCameraCaptureMode {
            switch self {
            case .Photo:
                return .Photo
            case .Video:
                return .Video
            }
        }
        
        func pathExtension() -> String {
            switch self {
            case .Photo:
                return "png"
            case .Video:
                return "mov"
            }
        }
    }
    
    public enum Source {
        case PhotoAlbum
        case Camera
        
        func toUIKit() -> UIImagePickerControllerSourceType {
            switch self {
            case .Camera:
                return .Camera
            case .PhotoAlbum:
                return .PhotoLibrary
            }
        }
    }

    private struct Request {
        let handler: MediaHandler
        let kind: Kind
    }
    
    private weak var presentingVC: UIViewController?
    private var currentRequest: Request?
    private let imagePicker = UIImagePickerController()

    public init(presentingVC: UIViewController) {
        self.presentingVC = presentingVC
        super.init()
    }
 
    public func getMedia(kind: Kind = .Photo, source: Source = .PhotoAlbum, handler: MediaHandler) {
        
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
        case .Video:
            imagePicker.mediaTypes = [kUTTypeMovie as String]
        case .Photo:
            imagePicker.mediaTypes = [kUTTypeImage as String]
        }
        
        presentingVC?.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        defer {
            self.currentRequest = nil
            picker.dismissViewControllerAnimated(true, completion: nil)
        }
        
        guard let currentRequest = self.currentRequest else { return }
        
        let validMedia: Bool = {
            guard let mediaTypeString = info[UIImagePickerControllerMediaType] as? String else { return false }
            switch currentRequest.kind {
            case .Video:
                return mediaTypeString == kUTTypeMovie as String
            case .Photo:
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
            try data.writeToURL(finalURL, options: [.DataWritingAtomic])
            self.currentRequest?.handler(finalURL)
        } catch {
            self.currentRequest?.handler(nil)
        }
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        currentRequest?.handler(nil)
        currentRequest = nil
    }
    
    private func cachePathForMedia(kind: Kind) -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        let cachesDirectory = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
        return cachesDirectory.URLByAppendingPathComponent("\(NSUUID().UUIDString).\(kind.pathExtension())")
    }
}
