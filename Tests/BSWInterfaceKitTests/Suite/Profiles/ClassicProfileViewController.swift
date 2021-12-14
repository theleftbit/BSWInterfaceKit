//
//  Created by Pierluigi Cifani on 03/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit
import Task
import BSWFoundation
import BSWInterfaceKit

public enum ClassicProfileEditKind {
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

open class ClassicProfileViewController: TransparentNavBarViewController, AsyncViewModelPresenter {

    public init(dataProvider: Task<ClassicProfileViewModel>) {
        self.dataProvider = dataProvider
        super.init(nibName:nil, bundle:nil)
    }
    
    public init(viewModel: ClassicProfileViewModel) {
        self.dataProvider = Task(success: viewModel)
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
    
    public var dataProvider: Task<ClassicProfileViewModel>!
    open var editKind: ClassicProfileEditKind = .nonEditable
    
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
    
    //MARK:- Private
    
    open func fetchData() {
        showLoader()
        dataProvider.upon(.main) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.hideLoader()
            switch result {
            case .failure(let error):
                strongSelf.showErrorMessage("Error fetching data", error: error)
            case .success(let viewModel):
                strongSelf.configureFor(viewModel: viewModel)
            }
        }
    }
    
    open func configureFor(viewModel: ClassicProfileViewModel) {
        photoGallery.photos = viewModel.photos
        titleLabel.attributedText = viewModel.titleInfo
        detailsLabel.attributedText = viewModel.detailsInfo
        extraDetailsLabel.attributedText = viewModel.extraInfo.joinedStrings()
    }
}

//MARK:- PhotoGalleryViewDelegate

extension ClassicProfileViewController: PhotoGalleryViewDelegate {
    public func didTapPhotoAt(index: Int, fromView: UIView) {
        guard #available(iOS 13, *) else {
            return
        }
        guard let viewModel = dataProvider.peek()?.value else { return }
        
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

//MARK:- PhotoGalleryViewControllerDelegate

@available(iOS 13, *)
extension ClassicProfileViewController: PhotoGalleryViewControllerDelegate {
    public func photoGalleryController(_ photoGalleryController: PhotoGalleryViewController, willDismissAtPageIndex index: Int) {
        photoGallery.scrollToPhoto(atIndex: index)
        dismiss(animated: true, completion: nil)
    }
}
#endif
