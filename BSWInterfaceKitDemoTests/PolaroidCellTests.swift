//
//  Created by Pierluigi Cifani on 20/03/2017.
//
//

import BSWInterfaceKit
@testable import BSWInterfaceKitDemo

@available(iOS 11.0, *)
class PolaroidCollectionViewCellTests: BSWSnapshotTest {

    func testLayout() {
        let cv = MockCollectionView()
        verify(view: cv)
    }

}

class MockCollectionView: UICollectionView {
    
    var mockDataSource: CollectionViewDataSource<PolaroidCollectionViewCell>!

    init() {
        let columnLayout = ColumnFlowLayout()
        super.init(frame: CGRect(x: 0, y: 0, width: 350, height: 500), collectionViewLayout: columnLayout)
        columnLayout.minColumnWidth = 120
        columnLayout.cellFactory = { [unowned self] indexPath in
            let cell = PolaroidCollectionViewCell()
            guard let vm = self.mockDataSource.data[safe: indexPath.item] else {
                return cell
            }
            cell.configureFor(viewModel: vm)
            return cell
        }
        mockDataSource = CollectionViewDataSource<PolaroidCollectionViewCell>(
            data: MockCollectionView.mockData(),
            collectionView: self
        )
        mockDataSource.pullToRefreshSupport = CollectionViewPullToRefreshSupport { completion in
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
