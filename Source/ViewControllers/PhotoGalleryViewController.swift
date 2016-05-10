//
//  Created by Pierluigi Cifani on 09/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation
import Cartography

public protocol PhotoGalleryViewControllerDelegate: class {
    func photoGalleryController(photoGalleryController: PhotoGalleryViewController, willDismissAtPageIndex index: UInt)
}

public class PhotoGalleryViewController: UIViewController {
    
    private let photosGallery: PhotoGalleryView
    public var allowShare: Bool
    public weak var presentFromView: UIView?
    public weak var delegate: PhotoGalleryViewControllerDelegate?
    public var currentPage: UInt = 0
    public var photos: [Photo] {
        return photosGallery.photos
    }

    public init(photos: [Photo],
         presentFromView: UIView? = nil,
         initialPageIndex: UInt = 0,
         allowShare: Bool = true) {
        self.presentFromView = presentFromView
        self.allowShare = allowShare
        self.photosGallery = PhotoGalleryView(photos: photos, imageContentMode: .ScaleAspectFit)
        self.currentPage = initialPageIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.blackColor()

        //Set up the Gallery
        view.addSubview(photosGallery)
        photosGallery.fillSuperview()
        
        //Add the close button
        let closeButton = UIButton(type: UIButtonType.Custom)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage.interfaceKitImageNamed("PhotoGalleryClose"), forState: UIControlState.Normal)
        closeButton.addTarget(self, action: #selector(onCloseButton), forControlEvents: .TouchDown)
        view.addSubview(closeButton)
        closeButton.trailingAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.trailingAnchor).active = true
        closeButton.topAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.topAnchor, constant: Stylesheet.margin(.Big)).active = true
        
        view.layoutIfNeeded()
        photosGallery.scrollToPhoto(atIndex: currentPage)
    }
    
    //MARK:- IBActions
    
    func onCloseButton() {
        delegate?.photoGalleryController(self, willDismissAtPageIndex: photosGallery.currentPage)
    }
}
