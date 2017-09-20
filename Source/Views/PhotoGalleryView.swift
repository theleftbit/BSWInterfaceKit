//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import BSWFoundation

// MARK: PhotoGalleryViewDelegate protocol

public protocol PhotoGalleryViewDelegate: class {
    func didTapPhotoAt(index: UInt, fromView: UIView)
}

// MARK: - PhotoGalleryView

final public class PhotoGalleryView: UIView {
    
    fileprivate let imageContentMode: UIViewContentMode
    fileprivate let scrollableStackView = ScrollableStackView(axis: .horizontal)
    
    fileprivate let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.hidesForSinglePage = true
        pageControl.pageIndicatorTintColor = UIColor.white
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        return pageControl
    }()
    
    public var photos = [Photo]() {
        didSet {
            layoutImageViews()
        }
    }
    
    fileprivate let updatePageControlOnScrollBehavior: UpdatePageControlOnScrollBehavior
    
    weak var delegate: PhotoGalleryViewDelegate?
    
    public var currentPage: UInt {
        return UInt(pageControl.currentPage)
    }
    
    // MARK: Initialization
    
    public init(photos: [Photo], imageContentMode: UIViewContentMode = .scaleAspectFill) {
        self.photos = photos
        self.imageContentMode = imageContentMode
        updatePageControlOnScrollBehavior = UpdatePageControlOnScrollBehavior(pageControl: pageControl)
        super.init(frame: CGRect.zero)
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
        let offset = CGPoint(x: imageView.frame.minX, y: scrollableStackView.contentOffset.y)
        scrollableStackView.setContentOffset(offset, animated: animated)
    }
}

// MARK: Initial view setup

extension PhotoGalleryView {
    
    fileprivate func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        // ScrollableStackView view
        addSubview(scrollableStackView)
        scrollableStackView.isPagingEnabled = true
        scrollableStackView.showsHorizontalScrollIndicator = false
        scrollableStackView.delegate = updatePageControlOnScrollBehavior
        
        // Page control
        addSubview(pageControl)
        
        // Image views
        layoutImageViews()
        
        // Constraints
        setupConstraints()
    }

    fileprivate func layoutImageViews() {
        
        scrollableStackView.removeAllArrangedViews()
        
        photos.forEach { photo in
            let imageView = createImageView(forPhoto: photo)
            scrollableStackView.addArrangedSubview(imageView)

            //Set the size of the imageView
            imageView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            imageView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
        }
        
        pageControl.numberOfPages = photos.count
    }
    
    fileprivate func createImageView(forPhoto photo: Photo) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = imageContentMode
        imageView.clipsToBounds = true
        
        imageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        imageView.setPhoto(photo)

        return imageView
    }
    
    // MARK: UI Action handlers
    
    @objc func handleTap(_ tapGestureRecognizer: UITapGestureRecognizer) {
        guard let view = tapGestureRecognizer.view else {
            return
        }
        guard let index = scrollableStackView.indexOfView(view) else {
            return
        }
        delegate?.didTapPhotoAt(index: UInt(index), fromView: view)
    }

    // MARK: Constraints

    fileprivate func setupConstraints() {
        scrollableStackView.pinToSuperview()
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CGFloat(Stylesheet.margin(.small)))
            ])
    }
}
