//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

// MARK: PhotoGalleryImage protocol

public protocol PhotoGalleryItem {
    var url: NSURL { get }
    var averageColor: UIColor { get }
}

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
    
    private var items = [PhotoGalleryItem]() {
        didSet {
            layoutImageViews()
        }
    }
    private let updatePageControlOnScrollBehavior: UpdatePageControlOnScrollBehavior
    
    weak var delegate: PhotoGalleryViewDelegate?
    
    // MARK: Initialization
    
    public init(items: [PhotoGalleryItem]) {
        self.items = items
        updatePageControlOnScrollBehavior = UpdatePageControlOnScrollBehavior(pageControl: pageControl)
        super.init(frame: CGRectZero)
        setup()
    }
    
    convenience public init() {
        self.init(items: [])
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
        pageControl.numberOfPages = items.count
        pageControl.currentPage = 0
        addSubview(pageControl)
        
        // Image views
        layoutImageViews()
        
        // Constraints
        setupConstraints()
    }

    private func layoutImageViews() {
        
        scrollableStackView.stackView.removeAllArrangedSubviews()
        
        items.forEach { image in
            let imageView = PhotoGalleryView.createImageView(image)
            scrollableStackView.stackView.addArrangedSubview(imageView)

            //Set the size of the imageView
            imageView.heightAnchor.constraintEqualToAnchor(self.heightAnchor).active = true
            imageView.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
        }
    }
    
    private static func createImageView(item: PhotoGalleryItem) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.userInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoGalleryView.handleTap(_:)))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        imageView.backgroundColor = item.averageColor
        imageView.bsw_setImageFromURL(item.url)

        return imageView
    }
    
    // MARK: UI Action handlers
    
    @objc func handleTap(tapGestureRecognizer: UITapGestureRecognizer) {
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

// MARK: Behaviour

final class UpdatePageControlOnScrollBehavior: NSObject {
    
    private weak var pageControl: UIPageControl?
    private let scrollingDirection: ScrollingDirection
    
    init(pageControl: UIPageControl, scrollingDirection: ScrollingDirection = .Horizontal) {
        self.pageControl = pageControl
        self.scrollingDirection = scrollingDirection
        super.init()
    }
    
    enum ScrollingDirection {
        case Horizontal, Vertical
    }
}

extension UpdatePageControlOnScrollBehavior: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard let pageControl = pageControl else { return }
        
        let isScrollingHorizontal = scrollingDirection == .Horizontal
        
        let viewBounds = scrollView.bounds
        let viewSize = isScrollingHorizontal ? CGRectGetWidth(viewBounds) : CGRectGetHeight(viewBounds)
        
        guard viewSize != 0 else { return }
        
        let contentOffset = scrollView.contentOffset
        let offset = isScrollingHorizontal ? contentOffset.x : contentOffset.y
        let adjustedOffset = offset + viewSize / 2
        
        let currentPage = Int(floor(adjustedOffset / viewSize))
        var normalizedCurrentPage = max(currentPage, 0)
        normalizedCurrentPage = min(normalizedCurrentPage, pageControl.numberOfPages - 1)
        
        pageControl.currentPage = normalizedCurrentPage
    }
}
