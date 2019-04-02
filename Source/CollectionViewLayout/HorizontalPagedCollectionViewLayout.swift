//
//  Created by Pierluigi Cifani on 28/03/2019.
//

import UIKit

public class HorizontalPagedCollectionViewLayout: UICollectionViewFlowLayout {
    
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

    public var velocityFactor: CGFloat = 0.1
    
    override public init() {
        super.init()
        scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override public func prepare() {
        super.prepare()
        guard let cv = self.collectionView else { return }
        assert(cv.isPagingEnabled == false)
        let availableSize = cv.frame.inset(by: sectionInset)
        itemSize = CGSize(width: availableSize.width - minimumLineSpacing, height: availableSize.height)
        cv.decelerationRate = .fast
    }
    
    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let cv = self.collectionView else { return proposedContentOffset }
        
        // Page width used for estimating and calculating paging.
        let pageWidth = self.itemSize.width + self.minimumLineSpacing
        
        // Make an estimation of the current page position.
        let approximatePage = cv.contentOffset.x/pageWidth
        
        // Determine the current page based on velocity.
        let currentPage = (velocity.x < 0.0) ? floor(approximatePage) : ceil(approximatePage)
        
        // Create custom flickVelocity.
        let flickVelocity = velocity.x * velocityFactor
        
        // Check how many pages the user flicked, if <= 1 then flickedPages should return 0.
        let flickedPages = (abs(round(flickVelocity)) <= 1) ? 0 : round(flickVelocity)
        
        // Calculate newHorizontalOffset.
        let newHorizontalOffset = ((currentPage + flickedPages) * pageWidth) - cv.contentInset.left
        
        return CGPoint(x: newHorizontalOffset, y: proposedContentOffset.y)
    }
}
