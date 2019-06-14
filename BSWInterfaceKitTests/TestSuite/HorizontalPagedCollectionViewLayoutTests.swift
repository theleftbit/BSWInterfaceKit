//
//  Created by Pierluigi Cifani on 28/03/2019.
//

import UIKit
import BSWInterfaceKit

class HorizontalPagedCollectionViewLayoutTests: BSWSnapshotTest {
    
    func testLayout() {
        let vc = ViewController(layout: HorizontalPagedCollectionViewLayout())
        waitABitAndVerify(viewController: vc)
    }

    func testAvailableWidthLayout() {
        let vc = ViewController(layout: HorizontalPagedCollectionViewLayout(itemSizing: .usingAvailableWidth(margin: 60)))
        waitABitAndVerify(viewController: vc)
    }
}

private class ViewController: UIViewController {
    
    var dataSource: CollectionViewDataSource<PageCell>!
    private let layout: HorizontalPagedCollectionViewLayout
    
    init(layout: HorizontalPagedCollectionViewLayout) {
        self.layout = layout
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        
        // Prepare the layout
        let mockData = [Photo](
            repeating: Photo.emptyPhoto(),
            count: 10
        )

        // Configure the SUT
        let horizontalLayout = layout
        horizontalLayout.minimumLineSpacing = ModuleConstants.Spacing
        horizontalLayout.sectionInset = [.left: ModuleConstants.Spacing, .right: ModuleConstants.Spacing]

        view = UIView()
        view.backgroundColor = .lightGray
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: horizontalLayout)
        collectionView.backgroundColor = .black
        dataSource = CollectionViewDataSource(data: mockData, collectionView: collectionView)
        view.addAutolayoutSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 300),
            ])
    }
}

private enum ModuleConstants {
    static let Spacing: CGFloat = 16
    static let MedSpacing: CGFloat = 30
}

private class PageCell: UICollectionViewCell, ViewModelReusable {
    
    let imageView = UIImageView()
    let colorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.purple.withAlphaComponent(0.85)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.contentMode = .scaleAspectFill
        contentView.addAutolayoutSubview(imageView)
        imageView.pinToSuperview()
        imageView.addAutolayoutSubview(colorView)
        colorView.pinToSuperview()
        contentView.roundCorners(radius: 22)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureFor(viewModel: Photo) {
        imageView.setPhoto(viewModel)
    }
}
