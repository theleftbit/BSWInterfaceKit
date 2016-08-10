//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography
import BSWFoundation

// MARK: PhotoGalleryViewDelegate protocol

public protocol PhotoGalleryViewDelegate: class {
    func didTapPhotoAt(index index: UInt, fromView: UIView)
}

// MARK: - PhotoGalleryView

final public class PhotoGalleryView: UIView {
    
    private let imageContentMode: UIViewContentMode
    private let scrollableStackView = ScrollableStackView(axis: .Horizontal)
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = UIColor.whiteColor()
        pageControl.pageIndicatorTintColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        return pageControl
    }()
    
    public var photos = [Photo]() {
        didSet {
            layoutImageViews()
        }
    }
    
    private let updatePageControlOnScrollBehavior: UpdatePageControlOnScrollBehavior
    
    weak var delegate: PhotoGalleryViewDelegate?
    
    public var currentPage: UInt {
        return UInt(pageControl.currentPage)
    }
    
    // MARK: Initialization
    
    public init(photos: [Photo], imageContentMode: UIViewContentMode = .ScaleAspectFill) {
        self.photos = photos
        self.imageContentMode = imageContentMode
        updatePageControlOnScrollBehavior = UpdatePageControlOnScrollBehavior(pageControl: pageControl)
        super.init(frame: CGRectZero)
        setup()
    }
    
    convenience public init() {
        self.init(photos: [])
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    

    public func scrollToPhoto(atIndex index: UInt, animated: Bool = false) {
        guard let imageView = scrollableStackView.viewAtIndex(Int(index)) else {
            return
        }
        let offset = CGPoint(x: CGRectGetMinX(imageView.frame), y: scrollableStackView.contentOffset.y)
        scrollableStackView.setContentOffset(offset, animated: animated)
    }
}

// MARK: Initial view setup

extension PhotoGalleryView {
    
    private func setup() {
        // ScrollableStackView view
        addSubview(scrollableStackView)
        scrollableStackView.pagingEnabled = true
        scrollableStackView.showsHorizontalScrollIndicator = false
        scrollableStackView.delegate = updatePageControlOnScrollBehavior
        
        // Page control
        addSubview(pageControl)
        
        // Image views
        layoutImageViews()
        
        // Constraints
        setupConstraints()
    }

    private func layoutImageViews() {
        
        scrollableStackView.removeAllArrangedViews()
        
        photos.forEach { photo in
            let imageView = createImageView(forPhoto: photo)
            scrollableStackView.addArrangedSubview(imageView)

            //Set the size of the imageView
            imageView.heightAnchor.constraintEqualToAnchor(heightAnchor).active = true
            imageView.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
        }
        
        pageControl.numberOfPages = photos.count
    }
    
    private func createImageView(forPhoto photo: Photo) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = imageContentMode
        imageView.clipsToBounds = true
        
        imageView.userInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        imageView.bsw_setPhoto(photo)

        return imageView
    }
    
    // MARK: UI Action handlers
    
    func handleTap(tapGestureRecognizer: UITapGestureRecognizer) {
        guard let view = tapGestureRecognizer.view else {
            return
        }
        guard let index = scrollableStackView.indexOfView(view) else {
            return
        }
        delegate?.didTapPhotoAt(index: UInt(index), fromView: view)
    }    
}

// MARK: Constraints

extension PhotoGalleryView {
    
    private func setupConstraints() {
        scrollableStackView.fillSuperview()

        constrain(pageControl) { pageControl in
            pageControl.centerX == pageControl.superview!.centerX
            pageControl.bottom == pageControl.superview!.bottom - CGFloat(Stylesheet.margin(.Small))
        }
    }
}
