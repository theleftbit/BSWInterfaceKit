//
//  Created by Pierluigi Cifani on 20/03/2017.
//
//

@testable import BSWInterfaceKit
import Deferred

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
        dataSource.pullToRefreshSupport = CollectionViewPullToRefreshSupport(handler: {
            let deferred = Deferred<CollectionViewPullToRefreshSupport<PolaroidCellViewModel>.Behavior>()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2), execute: {
                let vm1 = PolaroidCellViewModel(
                    cellImage: Photo.emptyPhoto(),
                    cellTitle: TextStyler.styler.attributedString("Francesco Totti", forStyle: .title),
                    cellDetails: TextStyler.styler.attributedString("#10", forStyle: .body)
                )
                deferred.fill(with: .insertOnTop([vm1]))
            })
            return Future(deferred)
        })
    }
    
    func testLayout() {
        waitABitAndVerify(view: collectionView)
    }

    static func mockData() -> [PolaroidCellViewModel] {

        let vm1 = PolaroidCellViewModel(
            cellImage: Photo.emptyPhoto(),
            cellTitle: TextStyler.styler.attributedString("Gigi Buffon", forStyle: .title),
            cellDetails: TextStyler.styler.attributedString("#1", forStyle: .body)
        )

        let vm2 = PolaroidCellViewModel(
            cellImage: Photo.emptyPhoto(),
            cellTitle: TextStyler.styler.attributedString("Gianluca Zambrotta", forStyle: .title),
            cellDetails: TextStyler.styler.attributedString("#19", forStyle: .body)
        )

        let vm3 = PolaroidCellViewModel(
            cellImage: Photo.emptyPhoto(),
            cellTitle: TextStyler.styler.attributedString("Fabio Cannavaro", forStyle: .title),
            cellDetails: TextStyler.styler.attributedString("#5", forStyle: .body)
        )

        let vm4 = PolaroidCellViewModel(
            cellImage: Photo.emptyPhoto(),
            cellTitle: TextStyler.styler.attributedString("Marco Materazzi", forStyle: .title),
            cellDetails: TextStyler.styler.attributedString("#23", forStyle: .body)
        )

        let vm5 = PolaroidCellViewModel(
            cellImage: Photo.emptyPhoto(),
            cellTitle: TextStyler.styler.attributedString("Fabio Grosso", forStyle: .title),
            cellDetails: TextStyler.styler.attributedString("#3", forStyle: .body)
        )

        return [vm1, vm2, vm3, vm4, vm5]
    }
}
