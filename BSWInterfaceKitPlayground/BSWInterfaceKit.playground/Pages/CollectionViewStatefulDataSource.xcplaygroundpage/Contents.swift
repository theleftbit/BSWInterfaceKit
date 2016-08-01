//: Please build the scheme 'BSWInterfaceKitPlayground' first
import XCPlayground
import BSWInterfaceKit
import BSWFoundation

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

extension Song: PolaroidCellViewModel {
    public var cellImage: Photo { return Photo(kind: .URL(NSURL(string: artWorkURL)!)) }
    public var cellTitle: NSAttributedString { return TextStyler.styler.attributedString(title, forStyle: .Title) }
    public var cellDetails: NSAttributedString { return TextStyler.styler.attributedString("\(songLenght) seconds", forStyle: .Body) }
}

class PlainListPresenter: ListStatePresenter {
    static let presenter = PlainListPresenter()
    func errorConfiguration(forError error: ErrorType) -> ErrorListConfiguration {
        return .Default(ActionableListConfiguration(title: TextStyler.styler.attributedString("Error", forStyle: .Title)))
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
    let collectionView = UICollectionView(frame: CGRectMake(0, 0, 500, 320), collectionViewLayout: collectionViewLayout)
    collectionView.backgroundColor = .lightGrayColor()
    return collectionView
}()

let dataSource = CollectionViewStatefulDataSource<Song, PolaroidCollectionViewCell>(
    collectionView: collectionView,
    listPresenter: PlainListPresenter.presenter,
    mapper: { song in
        return song
    }
)

let songs = [
    Song(title: "Milkshake", songLenght: 134, artWorkURL: "https://upload.wikimedia.org/wikipedia/en/2/2d/Kelis_milkshake.jpg"),
    Song(title: "Shake it Off", songLenght: 120, artWorkURL: "https://i.ytimg.com/vi/ufbHJjGJfeI/maxresdefault.jpg"),
]

dataSource.state = .Loaded(data: songs)

XCPlaygroundPage.currentPage.liveView = collectionView

let whatsGoingOn = XCPlaygroundPage.currentPage.liveView

XCPlaygroundPage.currentPage.finishExecution()
