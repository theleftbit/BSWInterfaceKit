//
//  Created by Pierluigi Cifani on 17/03/2017.
//

import BSWInterfaceKit
import BSWFoundation

enum FruitError: Error {
    case unknownError
}

class FruitViewController: UIViewController, ListStatePresenter {

    let dataSource: CollectionViewStatefulDataSource<PolaroidCollectionViewCell>
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: BSWCollectionViewFlowLayout())

    init() {
        dataSource = CollectionViewStatefulDataSource(collectionView: collectionView)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.pinToSuperview()
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        dataSource.listPresenter = self
        dataSource.updateState(.loading)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
            self.dataSource.updateState(.failure(error: FruitError.unknownError))
        }
    }

    func errorConfiguration(forError error: Error) -> ErrorListConfiguration {
        let retryButton = ButtonConfiguration(buttonTitle: .text(NSAttributedString(string: "Retry"))) { (_) in
            print("Retry")
        }
        let listConfig = ActionableListConfiguration(title: NSAttributedString(string: "\(error)"), buttonConfiguration: retryButton)

        return ErrorListConfiguration.default(listConfig)
    }

}
