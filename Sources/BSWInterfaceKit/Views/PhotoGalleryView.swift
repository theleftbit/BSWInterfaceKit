//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import BSWFoundation

#if compiler(>=5.9)
#Preview {
    PhotoGalleryView(photos: [
        .init(url: .init(string: "https://images.pexels.com/photos/2486168/pexels-photo-2486168.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2")!),
        .init(url: .init(string: "https://images.pexels.com/photos/1624496/pexels-photo-1624496.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2")!),
        .init(url: .init(string: "https://images.pexels.com/photos/1366919/pexels-photo-1366919.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2")!),
    ])
}
#endif

// MARK: PhotoGalleryViewDelegate protocol

public protocol PhotoGalleryViewDelegate: AnyObject {
    func didTapPhotoAt(index: Int, fromView: UIView)
}

// MARK: - PhotoGalleryView

/// This `UIView` subclass shows photos in a "gallery mode" much like you'd find in the details of a product of an e-commerce.
@objc(BSWPhotoGalleryView)
final public class PhotoGalleryView: UIView {
    
    enum Section: Hashable {
        case main
    }
    
    enum Item: Hashable {
        case photo(PhotoCollectionViewCell.Configuration)
    }

    private let imageContentMode: UIView.ContentMode
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var diffDataSource: UICollectionViewDiffableDataSource<Section, Item>!
    private var collectionViewLayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }

    public let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    var photos = [Photo]()
    private let updatePageControlOnScrollBehavior: UpdatePageControlOnScrollBehavior
    
    /// Sets the delegate for this object, in order to be notified of interactions.
    public weak var delegate: PhotoGalleryViewDelegate?
    
    /// Enables or disables the zoom for the photos.
    public var zoomEnabled = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    /// Returns the current page.
    public var currentPage: Int {
        return pageControl.currentPage
    }
    
    public override var backgroundColor: UIColor? {
        didSet {
            collectionView.backgroundColor = backgroundColor
        }
    }
    
    // MARK: Initialization
    
    /// Initializes this class with a given set of `Photos` and contentMode for it's images.
    /// - Parameters:
    ///   - photos: The photos to display
    ///   - imageContentMode: The contentMode for this images.
    public init(photos: [Photo] = [], imageContentMode: UIView.ContentMode = .scaleAspectFill) {
        self.imageContentMode = imageContentMode
        updatePageControlOnScrollBehavior = UpdatePageControlOnScrollBehavior(pageControl: pageControl, scrollView: collectionView)
        super.init(frame: .zero)
        setup()
        setPhotos(photos)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    

    /// Programatically scrolls to a given photo index.
    public func scrollToPhoto(atIndex index: Int, animated: Bool = false) {
        collectionView.scrollToItem(at: IndexPath(item: Int(index), section: 0), at: .centeredHorizontally, animated: animated)
    }

    public func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setNeedsLayout()
        scrollToPhoto(atIndex: pageControl.currentPage)
    }
    
    /// Changes the photos displayed by this view.
    public func setPhotos(_ photos: [Photo]) {
        self.photos = photos
        pageControl.numberOfPages = photos.count
        performPhotoInsertion()
    }

    // MARK: Private
    
    private func performPhotoInsertion() {
        var snapshot = diffDataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        self.photos.forEach { photo in
            let configuration = PhotoCollectionViewCell.Configuration(photo: photo, imageContentMode: self.imageContentMode, zoomEnabled: self.zoomEnabled)
            snapshot.appendItems([.photo(configuration)])
        }
        diffDataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false

        // CollectionView
        addSubview(collectionView)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionViewLayout.scrollDirection = .horizontal
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.minimumLineSpacing = 0
        
        // Page control
        addAutolayoutSubview(pageControl)
        pageControl.numberOfPages = photos.count

        // Do the layout
        collectionView.pinToSuperview()
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -4)
        ])
        let cellRegistration = PhotoCollectionViewCell.View.defaultCellRegistration()
        diffDataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .photo(let configuration):
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: configuration)
            }
        })
    }
}

// MARK: UICollectionViewDelegate

extension PhotoGalleryView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath), let view = cell.contentView as? PhotoCollectionViewCell.View else { return }
        delegate?.didTapPhotoAt(index: indexPath.item, fromView: view)
    }
}

extension PhotoGalleryView: UICollectionViewDelegateFlowLayout {

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.safeAreaLayoutGuide.layoutFrame.size
    }
}

extension PhotoGalleryView: UICollectionViewDataSourcePrefetching {
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let models: [URL] = indexPaths
            .compactMap({ self.photos[safe: $0.item] })
            .compactMap({
                switch $0.kind {
                case .url(let url, _):
                    return url
                default:
                    return nil
                }
            })
        UIImageView.prefetchImagesAtURL(models)
    }
}

#endif
