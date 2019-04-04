//
//  Created by Pierluigi Cifani on 28/03/2019.
//

import UIKit

public class HorizontalPagedCollectionViewLayout: UICollectionViewFlowLayout {
    
    public enum ItemSizing {
        case usingLineSpacing
        case usingAvailableWidth(margin: CGFloat)
    }
    
    override public var scrollDirection: UICollectionView.ScrollDirection {
        didSet {
            assert(scrollDirection == .horizontal)
        }
    }

    override public var minimumInteritemSpacing: CGFloat {
        didSet {
            fatalError("This has no meaning, please use minimumLineSpacing")
        }
    }

    public var onWillScrollToPage: (Int) -> Void = { _ in }
    
    public var velocityFactor: CGFloat = 0.1
    public let itemSizing: ItemSizing
    
    public init(itemSizing: ItemSizing = .usingLineSpacing) {
        self.itemSizing = itemSizing
        super.init()
        scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private var pageWidth: CGFloat {
        return self.itemSize.width + self.minimumLineSpacing
    }
    
    override public func prepare() {
        super.prepare()
        guard let cv = self.collectionView else { return }
        assert(cv.isPagingEnabled == false)
        let availableSize = cv.frame.inset(by: sectionInset)
        itemSize = {
            switch self.itemSizing {
            case .usingLineSpacing:
                return CGSize(width: availableSize.width - minimumLineSpacing, height: availableSize.height)
            case .usingAvailableWidth(let margin):
                return CGSize(width: availableSize.width - margin, height: availableSize.height)
            }
        }()
        cv.decelerationRate = .fast
    }
    
    public func targetContentOffset(forItemAtIndexPath indexPath: IndexPath) -> CGPoint {
        assert(indexPath.section == 0, "We're not ready for this yet")
        return CGPoint(x: CGFloat(indexPath.item)*pageWidth, y: 0)
    }

    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let cv = self.collectionView else { return proposedContentOffset }
        
        // Make an estimation of the current page position.
        let approximatePage = cv.contentOffset.x/pageWidth
        
        // Determine the current page based on velocity.
        let currentPage = (velocity.x < 0.0) ? floor(approximatePage) : ceil(approximatePage)
        
        // Create custom flickVelocity.
        let flickVelocity = velocity.x * velocityFactor
        
        // Check how many pages the user flicked, if <= 1 then flickedPages should return 0.
        let flickedPages = (abs(round(flickVelocity)) <= 1) ? 0 : round(flickVelocity)
        
        // Book keeping to make sure we don't go out of bounds.
        let targetPage = Int(currentPage + flickedPages)
        let pageCount = Int(cv.contentSize.width/pageWidth)
        guard targetPage >= 0, targetPage < pageCount else {
            return proposedContentOffset
        }
        
        // Notify that we're switching pages
        onWillScrollToPage(targetPage)
        
        // Calculate newHorizontalOffset.
        let newHorizontalOffset = (CGFloat(targetPage) * pageWidth) - cv.contentInset.left
        return CGPoint(x: newHorizontalOffset, y: proposedContentOffset.y)
    }
}
