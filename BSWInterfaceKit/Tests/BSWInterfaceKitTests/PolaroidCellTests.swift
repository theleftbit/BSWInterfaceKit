//
//  Created by Pierluigi Cifani on 20/03/2017.
//
//

import BSWInterfaceKit
import UIKit

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
        
        let vm1 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/vUMmWxu.jpg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Gigi Buffon", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#1", forStyle: .body)
        )
        
        let vm2 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/SPwnhVF.jpg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Gianluca Zambrotta", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#19", forStyle: .body)
        )
        
        let vm3 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/27RoHaJ.jpg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Fabio Cannavaro", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#5", forStyle: .body)
        )
        
        let vm4 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/4OLw6YE.jpg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Marco Materazzi", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#23", forStyle: .body)
        )
        
        let vm5 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/oM0WAGL.jpg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Fabio Grosso", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#3", forStyle: .body)
        )
        
        return [vm1, vm2, vm3, vm4, vm5]
    }
}
