//
//  Created by Pierluigi Cifani on 20/03/2017.
//
//

import BSWInterfaceKit
@testable import BSWInterfaceKitDemo

class PolaroidCollectionViewCellTests: BSWSnapshotTest {

    var collectionView: UICollectionView!
    var dataSource: CollectionViewStatefulDataSource<PolaroidCollectionViewCell>!

    override func setUp() {
        super.setUp()
        isDeviceAgnostic = false
        collectionView = WaterfallCollectionView(cellSizing: .dynamic({ (indexPath, constrainedToWidth) -> CGFloat in
            guard let model = self.dataSource.modelForIndexPath(indexPath) else { return 0 }
            return PolaroidCollectionViewCell.cellHeightForViewModel(model, constrainedToWidth: constrainedToWidth)
        }))
        collectionView.frame = CGRect(x: 0, y: 0, width: 350, height: 500)
        dataSource = CollectionViewStatefulDataSource<PolaroidCollectionViewCell>(
            state: .loaded(data: PolaroidCollectionViewCellTests.mockData()),
            collectionView: collectionView
        )
        dataSource.pullToRefreshSupport = CollectionViewPullToRefreshSupport { completion in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2), execute: {
                let vm1 = PolaroidCollectionViewCell.VM(
                    cellImage: Photo.emptyPhoto(),
                    cellTitle: TextStyler.styler.attributedString("Francesco Totti", forStyle: .title),
                    cellDetails: TextStyler.styler.attributedString("#10", forStyle: .body)
                )
                completion(CollectionViewPullToRefreshSupport<PolaroidCollectionViewCell.VM>.Behavior.insertOnTop([vm1]))
            })
        }
    }
    
    func testLayout() {
        waitABitAndVerify(view: collectionView)
    }

    static func mockData() -> [PolaroidCollectionViewCell.VM] {
        return FruitViewController.mockData()
    }
}
