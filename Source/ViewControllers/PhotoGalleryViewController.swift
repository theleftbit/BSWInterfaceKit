//
//  Created by Pierluigi Cifani on 09/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation
import IDMPhotoBrowser

public protocol PhotoGalleryViewControllerDelegate: class {
    func photoGalleryController(photoGalleryController: PhotoGalleryViewController, willDismissAtPageIndex index: UInt)
}

public class PhotoGalleryViewController: UIViewController {
    
    var photos: [Photo]
    var initialPageIndex: UInt
    var allowShare: Bool
    weak var presentFromView: UIView?
    weak var delegate: PhotoGalleryViewControllerDelegate?

    public init(photos: [Photo],
         presentFromView: UIView? = nil,
         initialPageIndex: UInt = 0,
         allowShare: Bool = true) {
        self.photos = photos
        self.presentFromView = presentFromView
        self.initialPageIndex = initialPageIndex
        self.allowShare = allowShare
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let browser = IDMPhotoBrowser(
            photos: photos.map({return $0.toIDMPhoto()}),
            animatedFromView: presentFromView
        )
        browser.usePopAnimation = true
        browser.displayCounterLabel = true
        browser.setInitialPageIndex(initialPageIndex)
        browser.displayActionButton = allowShare
        browser.delegate = self
        
        addChildViewController(browser)
        view.addSubview(browser.view)
        browser.view.fillSuperview()
        browser.didMoveToParentViewController(self)
    }
}

extension PhotoGalleryViewController: IDMPhotoBrowserDelegate {
    public func photoBrowser(photoBrowser: IDMPhotoBrowser!, willDismissAtPageIndex index: UInt) {
        delegate?.photoGalleryController(self, willDismissAtPageIndex: index)
    }
}

extension Photo {

    private func toIDMPhoto() -> IDMPhoto {
        switch self.kind {
        case .URL(let url):
            return IDMPhoto(URL: url)
        case .Image(let image):
            return IDMPhoto(image: image)
        }
    }
}