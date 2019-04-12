//
//  Created by Pierluigi Cifani on 27/09/2018.
//  Copyright © 2018 The Left Bit. All rights reserved.
//

import UIKit


@available(iOS 11.0, *)
open class ColumnFlowLayout: UICollectionViewLayout {
    
    // These are used to create a factory cell to calculate the size.
    // of the scrollable content of the collectionView. Please return
    // a configured cell for the given index path without using
    // dequeueCell like this:
    // https://i.imgur.com/LxYrTZB.png https://i.imgur.com/TCwbLeC.png
    public typealias CellFactory = (IndexPath) -> UICollectionViewCell
    public typealias HeaderFooterFactory = (IndexPath) -> UICollectionReusableView?

    open var cellFactory: CellFactory!

    open var headerFactory: HeaderFooterFactory = { _ in
        return nil
    }
    open var footerFactory: HeaderFooterFactory = { _ in
        return nil
    }

    open var minColumnWidth = CGFloat(200) {
        didSet {
            invalidateLayout()
        }
    }
    open var itemSpacing = CGFloat(10) {
        didSet {
            invalidateLayout()
        }
    }
    
    open var showsHeader: Bool = false {
        didSet {
            invalidateLayout()
        }
    }

    open var showsFooter: Bool = false {
        didSet {
            invalidateLayout()
        }
    }

    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var availableWidth: CGFloat {
        guard let cv = collectionView else { return 0 }
        return cv.bounds.inset(by: cv.layoutMargins).size.width
    }
    
    open override func invalidateLayout() {
        super.invalidateLayout()
        
        // Clear all cached values
        cache.removeAll()
        contentHeight = 0
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return false }
        return cv.bounds.size.width != newBounds.size.width
    }
    
    override open func prepare() {
        super.prepare()
        guard let cv = collectionView else { return }
        guard cache.isEmpty else { return }
        // Figure out how many columns we can fit
        let maxNumColumns = Int(availableWidth / minColumnWidth)
        let columnWidth = (availableWidth / CGFloat(maxNumColumns)).rounded(.down)
        let numberOfColumns = Int(availableWidth / columnWidth)
        let cellWidth = (availableWidth - CGFloat(numberOfColumns - 1)*itemSpacing)/CGFloat(numberOfColumns)
        
        // Figure out where each column starts in X
        let xOffset: [CGFloat] = {
            var offsets: [CGFloat] = []
            for currentColumn in 0 ..< numberOfColumns {
                if currentColumn == 0 {
                    offsets.append(cv.layoutMargins.left)
                } else {
                    let previousOffset = offsets[currentColumn - 1]
                    offsets.append(previousOffset + cellWidth + itemSpacing)
                }
            }
            return offsets
        }()
        
        // This is were we'll store the Y for each column: since layoutMargins
        // automatically include safeAreas, we're removing safeArea to use absolute values
        let numberOfItems = cv.numberOfItems(inSection: 0)
        guard numberOfItems > 0 else {
            return
        }
        
        var headerOffset: CGFloat = 0
        let headerIndexPath = IndexPath(item: 0, section: 0)
        let _header: UICollectionReusableView? = {
            guard showsHeader else {
                return nil
            }
            return self.headerFactory(headerIndexPath)
        }()
        
        if let header = _header {
            let headerWidth = cv.frame.width
            let height = ColumnFlowLayout.reusableViewHeight(view: header, availableWidth: headerWidth)
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: headerIndexPath)
            attributes.frame = CGRect(x: 0, y: 0, width: headerWidth, height: height)
            cache.append(attributes)
            headerOffset = attributes.frame.maxY
        }
        
        let yStartOffset = headerOffset > 0 ? headerOffset : (cv.layoutMargins.top - cv.safeAreaInsets.top)
        var yOffset = [CGFloat](repeating: yStartOffset, count: numberOfColumns)

        //Now we calculate the UICollectionViewLayoutAttributes for each cell
        var currentColumn: Int = 0
        for item in 0 ..< numberOfItems {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let cell = self.cellFactory(indexPath)
            let cellFrame: CGRect = {
                // Automatically calculate the height of the cell using Autolayout
                let height = ColumnFlowLayout.cellHeight(cell: cell, availableWidth: cellWidth)
                let frame = CGRect(x: xOffset[currentColumn], y: yOffset[currentColumn], width: cellWidth, height: height)
                let isFirstCellInColumn = (yOffset[currentColumn] == yStartOffset)
                return frame.offsetBy(dx: 0, dy: isFirstCellInColumn ? 0 : itemSpacing)
            }()
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = cellFrame
            cache.append(attributes)
            
            // Do some book-keeping to make sure the next
            // iteration uses the updated values
            contentHeight = max(contentHeight, cellFrame.maxY)
            yOffset[currentColumn] = cellFrame.maxY
            currentColumn = currentColumn < (numberOfColumns - 1) ? (currentColumn + 1) : 0
        }
        
        let _footer: UICollectionReusableView? = {
            guard showsFooter else {
                return nil
            }
            return self.footerFactory(headerIndexPath)
        }()
        
        if let footer = _footer {
            let footerWidth = cv.frame.width
            let height = ColumnFlowLayout.reusableViewHeight(view: footer, availableWidth: footerWidth)
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: headerIndexPath)
            attributes.frame = CGRect(x: 0, y: cache.last?.frame.maxY ?? 0, width: footerWidth, height: height)
            cache.append(attributes)
            contentHeight += height
        }

        contentHeight += cv.layoutMargins.bottom
    }
    
    override open var collectionViewContentSize: CGSize {
        return CGSize(width: availableWidth, height: contentHeight)
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect)}
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[safe: indexPath.item]
    }

    static func reusableViewHeight(view: UICollectionReusableView, availableWidth: CGFloat) -> CGFloat {
        let estimatedSize = view.systemLayoutSizeFitting(
            CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return estimatedSize.height
    }

    static func cellHeight(cell: UICollectionViewCell, availableWidth: CGFloat) -> CGFloat {
        let estimatedSize = cell.contentView.systemLayoutSizeFitting(
            CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return estimatedSize.height
    }
}
