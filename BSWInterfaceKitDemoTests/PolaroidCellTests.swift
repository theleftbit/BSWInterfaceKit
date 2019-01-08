//
//  Created by Pierluigi Cifani on 20/03/2017.
//
//

import BSWInterfaceKit
@testable import BSWInterfaceKitDemo

@available(iOS 11.0, *)
class PolaroidCollectionViewCellTests: BSWSnapshotTest {
    var collectionView: UICollectionView!
    var dataSource: CollectionViewDataSource<PolaroidCollectionViewCell>!

    override func setUp() {
        super.setUp()
        let columnLayout = ColumnFlowLayout()
        columnLayout.minColumnWidth = 120
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 350, height: 500), collectionViewLayout: columnLayout)
        dataSource = CollectionViewDataSource<PolaroidCollectionViewCell>(
            data: PolaroidCollectionViewCellTests.mockData(),
            collectionView: collectionView
        )
        dataSource.pullToRefreshSupport = CollectionViewPullToRefreshSupport { completion in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2), execute: {
                let vm1 = PolaroidCollectionViewCell.VM(
                    cellImage: Photo.emptyPhoto(),
                    cellTitle: TextStyler.styler.attributedString("Francesco Totti", forStyle: .title1),
                    cellDetails: TextStyler.styler.attributedString("#10", forStyle: .body)
                )
                completion(CollectionViewPullToRefreshSupport<PolaroidCollectionViewCell.VM>.Behavior.insertOnTop([vm1]))
            })
        }
    }
    
    func testLayout() {
        verify(view: collectionView)
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
