//
//  Created by Pierluigi Cifani on 20/03/2017.
//
//

import BSWInterfaceKit
@testable import BSWInterfaceKitDemo

class PolaroidCollectionViewCellTests: BSWSnapshotTest {
    var collectionView: WaterfallCollectionView!
    var dataSource: CollectionViewStatefulDataSource<PolaroidCollectionViewCell>!

    override func setUp() {
        super.setUp()
        isDeviceAgnostic = false
        collectionView = WaterfallCollectionView(cellSizing: .dynamic({ [unowned self] (indexPath, constrainedToWidth) -> CGFloat in
            guard let model = self.dataSource.modelForIndexPath(indexPath) else { return 0 }
            return PolaroidCollectionViewCell.cellHeightForViewModel(model, constrainedToWidth: constrainedToWidth)
        }))
        dataSource = CollectionViewStatefulDataSource<PolaroidCollectionViewCell>(
            state: .loaded(data: PolaroidCollectionViewCellTests.mockData()),
            collectionView: collectionView
        )
        dataSource.pullToRefreshSupport = CollectionViewPullToRefreshSupport { completion in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2), execute: {
                let vm1 = PolaroidCollectionViewCell.VM(
                    cellImage: Photo.emptyPhoto(),
                    cellTitle: TextStyler.styler.attributedString("Francesco Totti", forStyle: .headline),
                    cellDetails: TextStyler.styler.attributedString("#10", forStyle: .body)
                )
                completion(CollectionViewPullToRefreshSupport<PolaroidCollectionViewCell.VM>.Behavior.insertOnTop([vm1]))
            })
        }
    }
    
    func testCompactLayout() {
        let hostView = HostView(overridenTraitCollection: UITraitCollection(horizontalSizeClass: .compact), frame: CGRect(x: 0, y: 0, width: 350, height: 500))
        hostView.addAutolayoutSubview(collectionView)
        collectionView.pinToSuperview()
        waitABitAndVerify(view: collectionView)
    }

    func testRegularLayout() {

    }

    static func mockData() -> [PolaroidCollectionViewCell.VM] {
        return AzzurriViewController.mockData().map({
            return PolaroidCollectionViewCell.VM(
                cellImage: Photo.emptyPhoto(),
                cellTitle: $0.cellTitle,
                cellDetails: $0.cellDetails
            )
        })
    }
}

class HostView: UIView {
    init(overridenTraitCollection: UITraitCollection, frame: CGRect) {
        self.overridenTraitCollection = overridenTraitCollection
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var overridenTraitCollection: UITraitCollection!
    override var traitCollection: UITraitCollection {
        return overridenTraitCollection
    }
}
