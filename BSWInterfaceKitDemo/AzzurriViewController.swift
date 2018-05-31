//
//  Created by Pierluigi Cifani on 17/03/2017.
//

import BSWInterfaceKit
import BSWFoundation

enum FruitError: Error {
    case unknownError
}

class AzzurriViewController: UIViewController, ListStatePresenter {

    var dataSource: CollectionViewStatefulDataSource<PolaroidCollectionViewCell>!
    var collectionView: UICollectionView!

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView = WaterfallCollectionView(cellSizing: .dynamic({ (indexPath, constrainedToWidth) -> CGFloat in
            guard let model = self.dataSource.modelForIndexPath(indexPath) else { return 0 }
            return PolaroidCollectionViewCell.cellHeightForViewModel(model, constrainedToWidth: constrainedToWidth)
        }))
        dataSource = CollectionViewStatefulDataSource<PolaroidCollectionViewCell>(
            collectionView: collectionView
        )

        view.addSubview(collectionView)
        collectionView.pinToSuperview()
        collectionView.backgroundColor = .groupTableViewBackground
        collectionView.alwaysBounceVertical = true
        dataSource.listPresenter = self
        setEditing(false, animated: true)

        dataSource.updateState(.loading)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            self.dataSource.updateState(.loaded(data: AzzurriViewController.mockData()))
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, actionHandler: { [weak self] in
                guard let `self` = self else { return }
                self.setEditing(false, animated: true)
            })

            collectionView.visibleCells.forEach { cell in
                cell.isDeleting = true
                cell.onDelete = { [weak cell, weak self] in
                    guard let `cell` = cell else { return }
                    guard let index = self?.collectionView.indexPath(for: cell) else { return }
                    self?.removeItemAtIndexPath(index)
                }
            }

        } else {

            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, actionHandler: { [weak self] in
                guard let `self` = self else { return }
                self.setEditing(true, animated: true)
            })

            collectionView.visibleCells.forEach {
                $0.isDeleting = false
                $0.onDelete = nil
            }
        }
    }

    func removeItemAtIndexPath(_ indexPath: IndexPath) {
        dataSource.performEditActions([.remove(fromIndexPath: indexPath)])
    }

    func errorConfiguration(forError error: Error) -> ErrorListConfiguration {
        let retryButton = ButtonConfiguration(buttonTitle: .text(NSAttributedString(string: "Retry"))) {
            print("Retry")
        }
        let listConfig = ActionableListConfiguration(title: NSAttributedString(string: "\(error)"), buttonConfiguration: retryButton)

        return ErrorListConfiguration.default(listConfig)
    }

    static func mockData() -> [PolaroidCollectionViewCell.VM] {

        let vm1 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/vUMmWxu.jpg")!),
            cellTitle: TextStyler.styler.attributedString("Gigi Buffon", forStyle: .title),
            cellDetails: TextStyler.styler.attributedString("#1", forStyle: .body)
        )

        let vm2 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/SPwnhVF.jpg")!),
            cellTitle: TextStyler.styler.attributedString("Gianluca Zambrotta", forStyle: .title),
            cellDetails: TextStyler.styler.attributedString("#19", forStyle: .body)
        )

        let vm3 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/27RoHaJ.jpg")!),
            cellTitle: TextStyler.styler.attributedString("Fabio Cannavaro", forStyle: .title),
            cellDetails: TextStyler.styler.attributedString("#5", forStyle: .body)
        )

        let vm4 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/4OLw6YE.jpg")!),
            cellTitle: TextStyler.styler.attributedString("Marco Materazzi", forStyle: .title),
            cellDetails: TextStyler.styler.attributedString("#23", forStyle: .body)
        )

        let vm5 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/oM0WAGL.jpg")!),
            cellTitle: TextStyler.styler.attributedString("Fabio Grosso", forStyle: .title),
            cellDetails: TextStyler.styler.attributedString("#3", forStyle: .body)
        )

        return [vm1, vm2, vm3, vm4, vm5]
    }
}
