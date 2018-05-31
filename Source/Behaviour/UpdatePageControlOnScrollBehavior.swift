//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

final public class UpdatePageControlOnScrollBehavior: NSObject {
    
    fileprivate weak var pageControl: UIPageControl?
    fileprivate let scrollingDirection: ScrollingDirection
    fileprivate var observation: NSKeyValueObservation!

    init(pageControl: UIPageControl, scrollingDirection: ScrollingDirection = .horizontal, scrollView: UIScrollView) {
        self.pageControl = pageControl
        self.scrollingDirection = scrollingDirection
        super.init()

        observation = scrollView.observe(\.contentOffset) { [weak self] (scrollView, _) in
            self?.scrollViewDidScroll(scrollView)
        }
    }

    deinit {
        observation.invalidate()
    }
    
    enum ScrollingDirection {
        case horizontal, vertical
    }

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
