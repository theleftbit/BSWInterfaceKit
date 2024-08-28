//
//  Created by Pierluigi Cifani on 12/02/2017.
//
#if canImport(UIKit)

import BSWInterfaceKit
import UIKit
import Testing

/// This test is here because it tests several underlying subsystems
/// of BSWInterfaceKit so it works as some kind of "smoke test"
class ClassicProfileViewControllerTests: BSWSnapshotTest {

    @Test
    func sampleLayout() async {
        let viewModel = ClassicProfileViewModel.buffon()
        let detailVC = ClassicProfileViewController(viewModel: viewModel)
        detailVC.editKind = .editable(.init(title: "Edit", style: .plain, target: nil, action: nil))
        let navController = UINavigationController(rootViewController: detailVC)
        await waitTaskAndVerify(viewController: navController, testDarkMode: false)
    }
}

@MainActor
private class ClassicProfileViewController: UIViewController {

    enum ClassicProfileEditKind {
        case nonEditable
        case editable(UIBarButtonItem)
        
        public var isEditable: Bool {
            switch self {
            case .editable(_):
                return true
            default:
                return false
            }
        }
    }

    init(dataProvider: Task<ClassicProfileViewModel, Swift.Error>) {
        self.dataProvider = dataProvider
        super.init(nibName:nil, bundle:nil)
    }
    
    init(viewModel: ClassicProfileViewModel) {
        self.dataProvider = Task(operation: { return viewModel })
        super.init(nibName:nil, bundle:nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum Constants {
        static let SeparatorSize = CGSize(width: 30, height: 1)
        static let LayoutMargins = UIEdgeInsets(uniform: 8)
        static let PhotoGalleryRatio = CGFloat(0.78)
    }
    
    public var dataProvider: Task<ClassicProfileViewModel, Swift.Error>!
    open var editKind: ClassicProfileEditKind = .nonEditable
    
    private let scrollableStackView = ScrollableStackView()
    private let photoGallery = PhotoGalleryView()
    private let titleLabel = UILabel.unlimitedLinesLabel()
    private let detailsLabel = UILabel.unlimitedLinesLabel()
    private let extraDetailsLabel = UILabel.unlimitedLinesLabel()
    private let separatorView: UIView = {
        let view = UIView()
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: Constants.SeparatorSize.width),
            view.heightAnchor.constraint(equalToConstant: Constants.SeparatorSize.height)
            ])
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(scrollableStackView)
        scrollableStackView.pinToSuperview()

        //Add the photoGallery
        photoGallery.delegate = self
        scrollableStackView.addArrangedSubview(photoGallery)
        NSLayoutConstraint.activate([
            photoGallery.heightAnchor.constraint(equalTo: photoGallery.widthAnchor, multiplier: Constants.PhotoGalleryRatio),
            photoGallery.widthAnchor.constraint(equalTo: scrollableStackView.widthAnchor)
        ])
        
        scrollableStackView.addArrangedSubview(titleLabel, layoutMargins: Constants.LayoutMargins)
        scrollableStackView.addArrangedSubview(detailsLabel, layoutMargins: Constants.LayoutMargins)
        scrollableStackView.addArrangedSubview(separatorView, layoutMargins: Constants.LayoutMargins)
        scrollableStackView.addArrangedSubview(extraDetailsLabel, layoutMargins: Constants.LayoutMargins)

        //Add the rightBarButtonItem
        switch editKind {
        case .editable(let barButton):
            navigationItem.rightBarButtonItem = barButton
        default:
            break
        }
        
        fetchData()
    }
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Private
    
    open func fetchData() {
        fetchData(
            taskGenerator: { try await self.dataProvider.value },
            completion: {
                self.configureFor(viewModel: $0)
            })
    }
    
    open func configureFor(viewModel: ClassicProfileViewModel) {
        photoGallery.setPhotos(viewModel.photos)
        titleLabel.attributedText = viewModel.titleInfo
        detailsLabel.attributedText = viewModel.detailsInfo
        extraDetailsLabel.attributedText = viewModel.extraInfo.joinedStrings()
    }
}

//MARK: PhotoGalleryViewDelegate

extension ClassicProfileViewController: PhotoGalleryViewDelegate {
    public func didTapPhotoAt(index: Int, fromView: UIView) {
        Task { @MainActor in
            let viewModel = try await dataProvider.value
            let gallery = PhotoGalleryViewController(
                photos: viewModel.photos,
                initialPageIndex: index,
                allowShare: false
            )
            gallery.modalPresentationStyle = .overFullScreen
            gallery.delegate = self
            present(gallery, animated: true, completion: nil)
        }
    }
}

// MARK: PhotoGalleryViewControllerDelegate

extension ClassicProfileViewController: PhotoGalleryViewControllerDelegate {
    public func photoGalleryController(_ photoGalleryController: PhotoGalleryViewController, willDismissAtPageIndex index: Int) {
        photoGallery.scrollToPhoto(atIndex: index)
        dismiss(animated: true, completion: nil)
    }
}

#endif
