//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import Foundation

public typealias CellHeightForIndexPath = (IndexPath, CGFloat) -> CGFloat

public enum CellHeightType {
    case dynamic(CellHeightForIndexPath)
    case fixed(CGFloat)
}

open class WaterfallCollectionView: UICollectionView {
    
    public struct Configuration {
        let minimumColumnSpacing: CGFloat
        let minimumInteritemSpacing: CGFloat
        let sectionInset: UIEdgeInsets
        
        public static func defaultConfiguration() -> Configuration {
            return Configuration(
                minimumColumnSpacing: 10,
                minimumInteritemSpacing: 10,
                sectionInset: UIEdgeInsets(uniform: 10)
            )
        }
    }
    
    fileprivate var waterfallLayout: BSWCollectionViewWaterfallLayout {
        return collectionViewLayout as! BSWCollectionViewWaterfallLayout
    }
    
    open var columnCount: Int {
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
        
        super.init(frame: .zero, collectionViewLayout: waterfallLayout)
        
        waterfallLayout.delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static public func preferredColumnCountForTraitCollection(_ traitCollection: UITraitCollection) -> Int {
        switch traitCollection.horizontalSizeClass {
        case .compact:
            return 2
        case .regular:
            return 4
        default:
            return 2
        }
    }
}

extension WaterfallCollectionView: BSWCollectionViewDelegateWaterfallLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let width = waterfallLayout.itemWidthInSectionAtIndex((indexPath as NSIndexPath).section)
        guard width > 0 else { return .zero }

        let height: CGFloat = {
            switch self.cellHeight {
            case .fixed(let height):
                return height
            case .dynamic(let sizer):
                return sizer(indexPath, width)
            }
        }()
        
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnCountForSection section: Int) -> Int {
        return columnCount
    }
}
