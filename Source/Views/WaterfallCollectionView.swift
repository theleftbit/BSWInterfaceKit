//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

public typealias CellHeightForIndexPath = (NSIndexPath, CGFloat) -> CGFloat

public enum CellHeightType {
    case Dynamic(CellHeightForIndexPath)
    case Fixed(CGFloat)
}

public class WaterfallCollectionView: UICollectionView {
    
    public struct Configuration {
        let minimumColumnSpacing: CGFloat
        let minimumInteritemSpacing: CGFloat
        let sectionInset: UIEdgeInsets
        
        static func defaultConfiguration() -> Configuration {
            return Configuration(
                minimumColumnSpacing: 10,
                minimumInteritemSpacing: 10,
                sectionInset: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            )
        }
    }
    
    private var waterfallLayout: BSWCollectionViewWaterfallLayout {
        return collectionViewLayout as! BSWCollectionViewWaterfallLayout
    }
    
    public var columnCount: Int {
        didSet {
            waterfallLayout.columnCount = columnCount
        }
    }
    
    let cellHeight: CellHeightType
    
    public init(cellSizing: CellHeightType, configuration: Configuration = Configuration.defaultConfiguration(), columnCount: Int = 2) {
        self.columnCount = columnCount
        self.cellHeight = cellSizing
        
        let waterfallLayout = BSWCollectionViewWaterfallLayout()
        waterfallLayout.minimumColumnSpacing = configuration.minimumColumnSpacing
        waterfallLayout.minimumInteritemSpacing = configuration.minimumInteritemSpacing
        waterfallLayout.sectionInset = configuration.sectionInset
        
        super.init(frame: CGRectZero, collectionViewLayout: waterfallLayout)
        
        waterfallLayout.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static public func preferredColumnCountForTraitCollection(traitCollection: UITraitCollection) -> Int {
        switch traitCollection.horizontalSizeClass {
        case .Compact:
            return 2
        case .Regular:
            return 4
        default:
            return 2
        }
    }
}

extension WaterfallCollectionView: BSWCollectionViewDelegateWaterfallLayout {

    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = waterfallLayout.itemWidthInSectionAtIndex(indexPath.section)
        let height: CGFloat = {
            switch self.cellHeight {
            case .Fixed(let height):
                return height
            case .Dynamic(let sizer):
                return sizer(indexPath, width)
            }
        }()
        
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnCountForSection section: Int) -> Int {
        return columnCount
    }
}
