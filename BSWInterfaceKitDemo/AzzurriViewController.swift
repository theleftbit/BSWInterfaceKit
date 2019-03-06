//
//  Created by Pierluigi Cifani on 17/03/2017.
//

import BSWInterfaceKit
import BSWFoundation

enum FruitError: Error {
    case unknownError
}

@available(iOS 11.0, *)
class AzzurriViewController: UIViewController {

    var dataSource: CollectionViewDataSource<PolaroidCollectionViewCell>!
    var collectionView: UICollectionView!

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .groupTableViewBackground
        
        let columnLayout = ColumnFlowLayout()
        columnLayout.cellFactory = { [unowned self] in
            return self.factoryCellForItem(atIndexPath: $0)
        }
        columnLayout.minColumnWidth = 120
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: columnLayout)
        dataSource = CollectionViewDataSource<PolaroidCollectionViewCell>(
            collectionView: collectionView
        )

        view.addSubview(collectionView)
        collectionView.pinToSuperview()
        collectionView.backgroundColor = .groupTableViewBackground
        collectionView.alwaysBounceVertical = true
        
        let retryButton = ButtonConfiguration(buttonTitle: .text(NSAttributedString(string: "Retry"))) {
            print("Retry")
        }
        let emptyConfiguration = ErrorView.Configuration(title: NSAttributedString(string: "No more players"), buttonConfiguration: retryButton)
        dataSource.emptyConfiguration = emptyConfiguration
        
        setEditing(false, animated: true)

        self.showLoader()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
            self.hideLoader()
            self.dataSource.updateData(AzzurriViewController.mockData())
        }

    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (_) in
            self.collectionView.collectionViewLayout.invalidateLayout()
        }, completion: nil)
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


@available(iOS 11.0, *)
extension AzzurriViewController {
    func factoryCellForItem(atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = PolaroidCollectionViewCell()
        guard let vm = dataSource.data[safe: indexPath.item] else {
            return cell
        }
        cell.configureFor(viewModel: vm)
        return cell
    }
}
