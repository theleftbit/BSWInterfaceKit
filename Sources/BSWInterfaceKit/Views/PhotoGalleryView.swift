//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import BSWFoundation

// MARK: PhotoGalleryViewDelegate protocol

public protocol PhotoGalleryViewDelegate: AnyObject {
    func didTapPhotoAt(index: Int, fromView: UIView)
}

// MARK: - PhotoGalleryView

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
    private var diffDataSource: CollectionViewDiffableDataSource<Section, Item>!
    private var collectionViewLayout: UICollectionViewFlowLayout {
        return collectionView.collectionViewLayout as! UICollectionViewFlowLayout
    }

    public let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.hidesForSinglePage = true
        return pageControl
    }()
    
    public private(set) var photos = [Photo]()
    private let updatePageControlOnScrollBehavior: UpdatePageControlOnScrollBehavior
    
    public weak var delegate: PhotoGalleryViewDelegate?
    public var zoomEnabled = false {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public var currentPage: Int {
        return pageControl.currentPage
    }
    
    public override var backgroundColor: UIColor? {
        didSet {
            collectionView.backgroundColor = backgroundColor
        }
    }
    
    // MARK: Initialization
    
    public init(photos: [Photo] = [], imageContentMode: UIView.ContentMode = .scaleAspectFill) {
        self.photos = photos
        self.imageContentMode = imageContentMode
        updatePageControlOnScrollBehavior = UpdatePageControlOnScrollBehavior(pageControl: pageControl, scrollView: collectionView)
        super.init(frame: .zero)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    

    public func scrollToPhoto(atIndex index: Int, animated: Bool = false) {
        collectionView.scrollToItem(at: IndexPath(item: Int(index), section: 0), at: .centeredHorizontally, animated: animated)
    }

    public func invalidateLayout() {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.setNeedsLayout()
        scrollToPhoto(atIndex: pageControl.currentPage)
    }
    
    public func setPhotos(_ photos: [Photo]) async {
        self.photos = photos
        pageControl.numberOfPages = photos.count
        await performPhotoInsertion()
    }

    // MARK: Private
    
    private func performPhotoInsertion() async {
        var snapshot = diffDataSource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections([.main])
        self.photos.forEach { photo in
            let configuration = PhotoCollectionViewCell.Configuration(photo: photo, imageContentMode: self.imageContentMode, zoomEnabled: self.zoomEnabled)
            snapshot.appendItems([.photo(configuration)])
        }
        await diffDataSource.apply(snapshot)
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
