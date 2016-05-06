//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

final public class UpdatePageControlOnScrollBehavior: NSObject {
    
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
    public func scrollViewDidScroll(scrollView: UIScrollView) {
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
