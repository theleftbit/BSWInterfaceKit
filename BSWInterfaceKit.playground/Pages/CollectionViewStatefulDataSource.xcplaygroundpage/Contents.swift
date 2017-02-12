//: Please build the scheme 'BSWInterfaceKitPlayground' first
import PlaygroundSupport
import BSWInterfaceKit
import BSWFoundation

PlaygroundPage.current.needsIndefiniteExecution = true

extension PolaroidCellViewModel {
    init(song: Song) {
        self.cellImage = Photo(kind: .url(URL(string: song.artWorkURL)!))
        self.cellTitle = TextStyler.styler.attributedString(song.title, forStyle: .title)
        self.cellDetails = TextStyler.styler.attributedString("\(song.songLenght) seconds", forStyle: .body)
    }
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
    flowLayout.itemSize = CGSize(width: 240, height: 310)
    return flowLayout
}()

let collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: CGRect(x:0, y:0, width: 500, height: 650), collectionViewLayout: collectionViewLayout)
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
    Song(title: "Dale don Dale", songLenght: 100, artWorkURL: "https://i.imgur.com/ChnWmiK.png"),
]

let vm = songs.map { PolaroidCellViewModel(song: $0) }

dataSource.updateState(.loaded(data: vm))

PlaygroundPage.current.liveView = collectionView
