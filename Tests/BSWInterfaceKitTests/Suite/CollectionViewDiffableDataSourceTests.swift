
#if canImport(UIKit)

import BSWInterfaceKit
import UIKit

class CollectionViewDiffableDataSourceTests: BSWSnapshotTest {
    func testLayout() {
        let cv = MockCollectionView()
        let sut = cv.diffDataSource!
        var snapshot = sut.snapshot()
        snapshot.appendSections([.defenders, .midfields])
        snapshot.appendItems(MockCollectionView.mockDataDefenders().map({ .content($0)}), toSection: .defenders)
        sut.apply(snapshot, animatingDifferences: false)
        verify(scrollView: cv)
    }
}

private class ViewController: UIViewController {
    
    let collectionView = MockCollectionView()
    
    override func loadView() {
        view = collectionView
    }
}

private class MockCollectionView: UICollectionView {
    
    var diffDataSource: CollectionViewDiffableDataSource<Section, Item>!

    init() {
        let columnLayout = ColumnFlowLayout()
        super.init(frame: .zero, collectionViewLayout: columnLayout)
        columnLayout.minColumnWidth = 120
        columnLayout.cellFactory = { [unowned self] indexPath in
            let cell = PolaroidCollectionViewCell()
            if let item = self.diffDataSource.snapshot().itemIdentifiers(inSection: .defenders)[safe: indexPath.item], case .content(let vm) = item {
                cell.configureFor(viewModel: vm)
            }
            if let item = self.diffDataSource.snapshot().itemIdentifiers(inSection: .midfields)[safe: indexPath.item], case .content(let vm) = item {
                cell.configureFor(viewModel: vm)
            }
            return cell
        }
        
        diffDataSource = CollectionViewDiffableDataSource(collectionView: self, cellProvider: { (cv, index, item) -> UICollectionViewCell? in
            let cellRegistration = UICollectionView.CellRegistration<PolaroidCollectionViewCell, Item> { cell, indexPath, item in
                guard case .content(let vm) = item else { fatalError() }
                cell.configureFor(viewModel: vm)
            }
            return cv.dequeueConfiguredReusableCell(using: cellRegistration, for: index, item: item)
        })
        
        diffDataSource.emptyConfiguration = .init(title: TextStyler.styler.attributedString("Empty View", color: .red), message: nil, image: nil, button: nil)
        diffDataSource.pullToRefreshProvider = .init(tintColor: .blue, fetchHandler: { snapshot in
            snapshot.appendItems(MockCollectionView.mockDataMidfields().map({ .content($0)}), toSection: .midfields)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func mockDataDefenders() -> [PolaroidCollectionViewCell.VM] {
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
    
    static func mockDataMidfields() -> [PolaroidCollectionViewCell.VM] {
        let vm1 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/HTo6Xmm.jpg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Gattuso", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#8", forStyle: .body)
        )
        
        let vm2 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/ZH3wAf8.jpeg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Pirlo", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#21", forStyle: .body)
        )
        
        return [vm1, vm2]
    }
}


private enum Section { case defenders, midfields }
private enum Item: PagingCollectionViewItem, Hashable {
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
    
    static func loadingItem() -> Item {
        Item.loading
    }
}

#endif
