
import UIKit

/// TODO:
/// - Pull to refresh
/// - Paging
/// - Empty View
/// Reorder and SupplementaryView are handled by `UICollectionViewDiffableDataSource`
@available(iOS 13.0, *)
class BSWCollectionViewDiffableDataSource<SectionIdentifierType: Hashable, ItemIdentifierType: Hashable>: UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType> {
    
    public weak var collectionView: UICollectionView!
    
    override init(collectionView: UICollectionView, cellProvider: @escaping UICollectionViewDiffableDataSource<SectionIdentifierType, ItemIdentifierType>.CellProvider) {
        super.init(collectionView: collectionView, cellProvider: cellProvider)
        self.collectionView = collectionView
    }
    
    public var infiniteScrollSupport: CollectionViewInfiniteScrollSupport<ItemIdentifierType>? {
        didSet {

        }
    }
}
