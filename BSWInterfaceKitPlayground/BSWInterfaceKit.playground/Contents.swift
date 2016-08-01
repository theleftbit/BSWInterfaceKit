//: Please build the scheme 'BSWInterfaceKitPlayground' first
import XCPlayground
import BSWInterfaceKit
import BSWFoundation

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

struct Song {
    let title: String
    let songLenght: NSTimeInterval
    let artWorkURL: String
}

extension Song: PolaroidCellViewModel {
    var cellImage: Photo { return Photo(kind: .URL(NSURL(string: artWorkURL)!)) }
    var cellTitle: NSAttributedString { return TextStyler.styler.attributedString(title, forStyle: .Title) }
    var cellDetails: NSAttributedString { return TextStyler.styler.attributedString("\(songLenght)", forStyle: .Body) }
}

private func mapper(model: Song) -> PolaroidCellViewModel {
    return model
}

let collectionView = UICollectionView(frame: CGRectMake(0, 0, 500, 500), collectionViewLayout: {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 2.5
    flowLayout.itemSize = CGSize(width: 240, height: 310)
    return flowLayout
}())

collectionView.backgroundColor = .lightGrayColor()

let dataSource = CollectionViewStatefulDataSource<Song, PolaroidCollectionViewCell>(collectionView: collectionView, listPresenter: nil, mapper: mapper)

let songs = [
    Song(title: "Milkshake", songLenght: 120, artWorkURL: "https://upload.wikimedia.org/wikipedia/en/2/2d/Kelis_milkshake.jpg"),
    Song(title: "Shake it Off", songLenght: 120, artWorkURL: "https://i.ytimg.com/vi/ufbHJjGJfeI/maxresdefault.jpg"),
]

dataSource.state = .Loaded(data: songs)

XCPlaygroundPage.currentPage.liveView = collectionView
let whatsGoingOn = XCPlaygroundPage.currentPage.liveView

XCPlaygroundPage.currentPage.finishExecution()
