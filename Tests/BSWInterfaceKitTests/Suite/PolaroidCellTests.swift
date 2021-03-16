
#if canImport(UIKit)

import BSWInterfaceKit
import UIKit

@available(iOS 14.0, *)
class PolaroidCollectionViewCellTests: BSWSnapshotTest {
    func testLayout() {
        let cv = MockCollectionView()
        verify(scrollView: cv)
    }
}

@available(iOS 14.0, *)
class MockCollectionView: UICollectionView {
    
    private var mockDataSource: CollectionViewDiffableDataSource<Section, Item>!

    init() {
        let columnLayout = ColumnFlowLayout()
        super.init(frame: .zero, collectionViewLayout: columnLayout)
        columnLayout.minColumnWidth = 120
        columnLayout.cellFactory = { [unowned self] indexPath in
            let cell = PolaroidCollectionViewCell()
            guard let item = self.mockDataSource.snapshot().itemIdentifiers(inSection: .main)[safe: indexPath.item], case .content(let vm) = item else {
                return cell
            }
            cell.configureFor(viewModel: vm)
            return cell
        }
        
        mockDataSource = CollectionViewDiffableDataSource.init(collectionView: self, cellProvider: { (cv, index, item) -> UICollectionViewCell? in
            let cellRegistration = UICollectionView.CellRegistration<PolaroidCollectionViewCell, Item> { cell, indexPath, item in
                guard case .content(let vm) = item else { fatalError() }
                cell.configureFor(viewModel: vm)
            }
            return cv.dequeueConfiguredReusableCell(using: cellRegistration, for: index, item: item)
        })
        var snapshot = mockDataSource.snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(MockCollectionView.mockData().map({ .content($0)}), toSection: .main)
        mockDataSource.apply(snapshot, animatingDifferences: false)
//        mockDataSource.pullToRefreshSupport = CollectionViewPullToRefreshSupport { completion in
//            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2), execute: {
//                let vm1 = PolaroidCollectionViewCell.VM(
//                    cellImage: Photo.emptyPhoto(),
//                    cellTitle: TextStyler.styler.attributedString("Francesco Totti", forStyle: .title1),
//                    cellDetails: TextStyler.styler.attributedString("#10", forStyle: .body)
//                )
//                completion(CollectionViewPullToRefreshSupport<PolaroidCollectionViewCell.VM>.Behavior.insertOnTop([vm1]))
//            })
//        }
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

    private enum Section { case main }
    private enum Item: CollectionViewDiffableItemWithLoading, Hashable {
        case loading
        case content(PolaroidCollectionViewCell.VM)
        var isLoading: Bool {
            switch self {
            case .loading:
                return true
            default:
                return false
            }
        }
        
        static func loadingItem() -> MockCollectionView.Item {
            MockCollectionView.Item.loading
        }
    }
}

#endif
