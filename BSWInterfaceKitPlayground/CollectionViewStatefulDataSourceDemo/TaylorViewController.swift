
import UIKit
import BSWInterfaceKit

//MARK:- TaylorViewController

public class TaylorViewController: UIViewController {
    
    private var collectionView: WaterfallCollectionView!
    
    private var dataSource: CollectionViewStatefulDataSource<Song, PolaroidCollectionViewCell>!
    
    private let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.LongStyle
        formatter.timeStyle = .MediumStyle
        return formatter
    }()
    
    override public func viewDidLoad() {
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
        
        dataSource.state = .Loading
        fetchSongs { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .Failure(let error):
                strongSelf.dataSource.state = .Failure(error: error)
            case .Success(let data):
                strongSelf.dataSource.state = .Loaded(data: data)
            }
        }
    }
    
    private func mapper(song: Song) -> PolaroidCellViewModel {
        
        struct SongViewModel: PolaroidCellViewModel {
            let cellImage: Photo
            let cellTitle: NSAttributedString
            let cellDetails: NSAttributedString
        }
        
        return SongViewModel(
            cellImage: Photo(kind: .URL(song.thumbnail), size: CGSize(width: 300, height: 300)),
            cellTitle: TextStyler.styler.attributedString(song.name, forStyle: .Headline),
            cellDetails: TextStyler.styler.attributedString(dateFormatter.stringFromDate(song.releaseDate), forStyle: .Body)
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
    
    public func errorConfiguration(forError error: ErrorType) -> ErrorListConfiguration {
        
        let listConfig = ActionableListConfiguration(
            title: NSAttributedString(string: "There was an error: \(error)"),
            buttonConfiguration: ButtonConfiguration(title: NSAttributedString(string: "Retry")) {
                self.fetchData()
            }
        )
        
        return ErrorListConfiguration.Default(listConfig)
    }
}

