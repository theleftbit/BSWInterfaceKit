//: Please build the scheme 'BSWInterfaceKitPlayground' first
import PlaygroundSupport
import BSWInterfaceKit
import BSWFoundation

PlaygroundPage.current.needsIndefiniteExecution = true

extension Song: PolaroidCellViewModel {
    public var cellImage: Photo { return Photo(kind: .url(URL(string: artWorkURL)!)) }
    public var cellTitle: NSAttributedString { return TextStyler.styler.attributedString(title, forStyle: .title) }
    public var cellDetails: NSAttributedString { return TextStyler.styler.attributedString("\(songLenght) seconds", forStyle: .body) }
}

class PlainListPresenter: ListStatePresenter {
    static let presenter = PlainListPresenter()
    func errorConfiguration(forError error: Error) -> ErrorListConfiguration {
        return .default(ActionableListConfiguration(title: TextStyler.styler.attributedString("Error", forStyle: .title)))
    }
}

let collectionViewLayout: UICollectionViewFlowLayout = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 2.5
    flowLayout.itemSize = CGSize(width: 240, height: 310)
    return flowLayout
}()

let collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: CGRect(x:0, y:0, width: 500, height: 320), collectionViewLayout: collectionViewLayout)
    collectionView.backgroundColor = .lightGray
    return collectionView
}()

let dataSource = CollectionViewStatefulDataSource<PolaroidCollectionViewCell>(
    collectionView: collectionView,
    listPresenter: PlainListPresenter.presenter
)

let songs = [
    Song(title: "Milkshake", songLenght: 134, artWorkURL: "http://ow.ly/ZGln302NKHF"),
    Song(title: "Shake it Off", songLenght: 120, artWorkURL: "http://ow.ly/ow2o302NKJ1"),
]

dataSource.updateState(.loaded(data: songs))

PlaygroundPage.current.liveView = collectionView
