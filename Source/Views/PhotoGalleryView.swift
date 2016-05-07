//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

// MARK: PhotoGalleryViewDelegate protocol

public protocol PhotoGalleryViewDelegate: class {
    func didTapPhotoAt(index index: Int, fromView: UIView)
}

// MARK: - PhotoGalleryView

final public class PhotoGalleryView: UIView {
    
    private let scrollableStackView = ScrollableStackView(axis: .Horizontal)
    
    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = UIColor.whiteColor()
        pageControl.pageIndicatorTintColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        return pageControl
    }()
    
    private var photos = [Photo]() {
        didSet {
            layoutImageViews()
        }
    }
    private let updatePageControlOnScrollBehavior: UpdatePageControlOnScrollBehavior
    
    weak var delegate: PhotoGalleryViewDelegate?
    
    // MARK: Initialization
    
    public init(photos: [Photo]) {
        self.photos = photos
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
}

// MARK: Initial view setup

extension PhotoGalleryView {
    
    private func setup() {
        // ScrollableStackView view
        addSubview(scrollableStackView)
        scrollableStackView.scrollView.pagingEnabled = true
        scrollableStackView.scrollView.showsHorizontalScrollIndicator = false
        scrollableStackView.scrollView.delegate = updatePageControlOnScrollBehavior
        
        // Page control
        pageControl.numberOfPages = photos.count
        pageControl.currentPage = 0
        addSubview(pageControl)
        
        // Image views
        layoutImageViews()
        
        // Constraints
        setupConstraints()
    }

    private func layoutImageViews() {
        
        scrollableStackView.stackView.removeAllArrangedSubviews()
        
        photos.forEach { photo in
            let imageView = createImageView(forPhoto: photo)
            scrollableStackView.stackView.addArrangedSubview(imageView)

            //Set the size of the imageView
            imageView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
            imageView.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
        }
    }
    
    private func createImageView(forPhoto photo: Photo) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
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
        guard let index = scrollableStackView.stackView.arrangedSubviews.indexOf(view) else {
            return
        }
        delegate?.didTapPhotoAt(index: index, fromView: view)
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
