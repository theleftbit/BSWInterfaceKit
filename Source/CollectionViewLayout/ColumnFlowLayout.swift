//
//  Created by Pierluigi Cifani on 27/09/2018.
//  Copyright © 2018 The Left Bit. All rights reserved.
//

import UIKit

open class ColumnFlowLayout: UICollectionViewLayout {
    
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
        
        // This is were we'll store the Y for each column
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        //Now we calculate the UICollectionViewLayoutAttributes for each cell
        var currentColumn: Int = 0
        for item in 0 ..< cv.numberOfItems(inSection: 0) {
            
            let indexPath = IndexPath(item: item, section: 0)
            guard let cell = cv.dataSource?.collectionView(cv, cellForItemAt: indexPath) else { fatalError() }
            
            // Automatically calculate the height of the cell using Autolayout
            let height = ColumnFlowLayout.cellHeight(cell: cell, availableWidth: cellWidth)
            let frame = CGRect(x: xOffset[currentColumn], y: yOffset[currentColumn], width: cellWidth, height: height)
            let insetFrame = frame.offsetBy(dx: 0, dy: itemSpacing)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // Do some book-keeping to make sure the next
            // iteration uses the updated values
            contentHeight = max(contentHeight, insetFrame.maxY)
            yOffset[currentColumn] = insetFrame.maxY
            currentColumn = currentColumn < (numberOfColumns - 1) ? (currentColumn + 1) : 0
        }
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
    
    static func cellHeight(cell: UICollectionViewCell, availableWidth: CGFloat) -> CGFloat {
        let estimatedSize = cell.contentView.systemLayoutSizeFitting(
            CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return estimatedSize.height
    }
}
