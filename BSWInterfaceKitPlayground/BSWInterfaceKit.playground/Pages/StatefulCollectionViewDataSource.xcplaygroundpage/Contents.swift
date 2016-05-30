import XCPlayground
import BSWInterfaceKit

//MARK:- TaylorViewController

class TaylorViewController: UIViewController {
    
    private var collectionView: WaterfallCollectionView!
    
    private var dataSource: CollectionViewStatefulDataSource<Song, PolaroidCollectionViewCell>!
    
    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Taylor Swift's Songs"
        
        //Create the collectionView
        collectionView = WaterfallCollectionView(cellSizing: .Dynamic(cellSizeForIndexPath))
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.lightGrayColor()
        
        //Layout the collectionView
        view.addSubview(collectionView)
        collectionView.fillSuperview()
        
        //Prepare dataSource
        dataSource = CollectionViewStatefulDataSource<Song, PolaroidCollectionViewCell>(
            state: .Loading,
            collectionView: collectionView,
            listPresenter: self,
            mapper: mapper
        )
        
        fetchData()
    }
    
    //MARK: Private
    
    private func fetchData() {
    
    }
    
    private func mapper(song: Song) -> PolaroidCellViewModel {
        
        struct SongViewModel: PolaroidCellViewModel {
            let cellImage: Photo
            let cellTitle: NSAttributedString
            let cellDetails: NSAttributedString
        }
        
        
        return SongViewModel(
            cellImage: Photo(kind: .URL(song.thumbnail)),
            cellTitle: NSAttributedString(string: song.name),
            cellDetails: NSAttributedString(string: dateFormatter.stringFromDate(song.releaseDate))
        )
    }
    
    private func cellSizeForIndexPath(indexPath: NSIndexPath, constrainedToWidth: CGFloat) -> CGFloat {
        guard let song = dataSource.modelForIndexPath(indexPath) else { return CGFloat(0) }
        return PolaroidCollectionViewCell.cellHeightForViewModel(mapper(song), constrainedToWidth: constrainedToWidth)
    }
}

//MARK: - UICollectionViewDelegate

extension TaylorViewController: UICollectionViewDelegate { }

//MARK:- ListStatePresenter

extension TaylorViewController: ListStatePresenter {
    
    func errorConfiguration(forError error: ErrorType) -> ErrorListConfiguration {
        
        let listConfig = ActionableListConfiguration(
            title: NSAttributedString(string: "There was an error"),
            buttonConfiguration: ButtonConfiguration(title: NSAttributedString(string: "Retry")) {
                self.fetchData()
            }
        )
        
        return ErrorListConfiguration.Default(listConfig)
    }
}

let taylorVC = TaylorViewController()
let navController = UINavigationController(rootViewController: taylorVC)
navController.view.frame = CGRect(x: 0, y: 0, width: 320, height: 568)

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
XCPlaygroundPage.currentPage.liveView = navController.view

