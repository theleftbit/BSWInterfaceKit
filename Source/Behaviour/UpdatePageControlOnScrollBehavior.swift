//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

final public class UpdatePageControlOnScrollBehavior: NSObject {
    
    fileprivate weak var pageControl: UIPageControl?
    fileprivate let scrollingDirection: ScrollingDirection
    
    init(pageControl: UIPageControl, scrollingDirection: ScrollingDirection = .horizontal) {
        self.pageControl = pageControl
        self.scrollingDirection = scrollingDirection
        super.init()
    }
    
    enum ScrollingDirection {
        case horizontal, vertical
    }
}

extension UpdatePageControlOnScrollBehavior: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let pageControl = pageControl else { return }
        
        let isScrollingHorizontal = scrollingDirection == .horizontal
        
        let viewBounds = scrollView.bounds
        let viewSize = isScrollingHorizontal ? viewBounds.width : viewBounds.height
        
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
