//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

//MARK: Cells

@available(iOS 9.0, *)
@objc(BSWPolaroidCollectionViewCell)
open class PolaroidCollectionViewCell: UICollectionViewCell, ViewModelReusable {

    //MARK: ViewModel
    public struct VM {
        public let id: Int?
        public let cellImage: Photo
        public let cellTitle: NSAttributedString
        public let cellDetails: NSAttributedString

        public init(id: Int? = nil, cellImage: Photo, cellTitle: NSAttributedString, cellDetails: NSAttributedString) {
            self.id = id
            self.cellImage = cellImage
            self.cellTitle = cellTitle
            self.cellDetails = cellDetails
        }
    }

    fileprivate let detailSubview = PolaroidCollectionCellBasicInfoView()
    
    fileprivate let cellImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    fileprivate let stackView = UIStackView()

    fileprivate static let MaxImageHeightProportion = CGFloat(2)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.backgroundColor = UIColor.clear
        cellImageView.cancelImageLoadFromURL()
        cellImageView.image = nil
    }
    
    fileprivate func setup() {
        stackView.addArrangedSubview(cellImageView)
        stackView.addArrangedSubview(detailSubview)
        stackView.axis = .vertical
        contentView.addAutolayoutSubview(stackView)
        stackView.pinToSuperview()

        setupConstraints()
        setupRoundedCorners()
        layer.addShadow(opacity: 0.1, shadowRadius: 4)
        
        contentView.layoutIfNeeded()
    }
    
    /// This is a placeholder constraint to make sure that when doing the final
    /// layout for the wanted viewModel, the image height is not compressed
    fileprivate var imageHeightConstraint: NSLayoutConstraint!
    
    fileprivate func setupConstraints() {
        imageHeightConstraint = cellImageView.heightAnchor.constraint(equalToConstant: 80)
        imageHeightConstraint.priority = .required
        NSLayoutConstraint.activate([imageHeightConstraint])
    }
    
    fileprivate func setupRoundedCorners() {
        contentView.roundCorners()
    }
    
    open func configureFor(viewModel: VM) {

        //Set the basic info
        detailSubview.setTitle(viewModel.cellTitle, subtitle: viewModel.cellDetails)

        //Set the image
        cellImageView.setPhoto(viewModel.cellImage)
        
        // Make sure that the image is not compressed when doing the final
        // layout by setting it's height to the wanted for a given height
        imageHeightConstraint.constant = PolaroidCollectionViewCell.cellImageHeightForViewModel(viewModel, constrainedToWidth: contentView.frame.width)
        setNeedsLayout()
    }
}

//MARK: - Subviews

@objc(BSWPolaroidCollectionCellBasicInfoView)
private class PolaroidCollectionCellBasicInfoView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = Stylesheet.margin(.smallest)
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: NSAttributedString? =  nil, subtitle: NSAttributedString? = nil) {
        titleLabel.attributedText = title
        detailLabel.attributedText = subtitle
    }
    
    fileprivate func setup() {
        backgroundColor = UIColor.white
        setContentCompressionResistancePriority(UILayoutPriority.required, for: .vertical)
        
        addAutolayoutSubview(stackView)
        stackView.fillSuperview(withMargin: Stylesheet.margin(.medium))
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(detailLabel)
    }
}

//MARK: - Height calculation

@available(iOS 9.0, *)
extension PolaroidCollectionViewCell {
    
    fileprivate struct PolaroidCollectionViewCellHeightCalculator {
        fileprivate static let BasicInfoView = PolaroidCollectionCellBasicInfoView()
    }
    
    fileprivate static func cellImageHeightForViewModel(_ viewModel: VM, constrainedToWidth width: CGFloat) -> CGFloat {
        let maxImageHeight = PolaroidCollectionViewCell.MaxImageHeightProportion * width
        let imageSize = viewModel.cellImage.estimatedSize ?? CGSize(width: width, height: width)
        let imageHeight = min(maxImageHeight, width * CGFloat(imageSize.height) / CGFloat(imageSize.width))
        return imageHeight
    }
    
    fileprivate static func cellInfoHeightForViewModel(_ viewModel: VM, constrainedToWidth width: CGFloat) -> CGFloat {
        let infoView = PolaroidCollectionViewCellHeightCalculator.BasicInfoView
        infoView.setTitle(viewModel.cellTitle, subtitle: viewModel.cellDetails)
        let fittingSize = infoView.systemLayoutSizeFitting(
            CGSize(width: width, height: 0),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
            )
        return fittingSize.height
    }
    
    static public func cellHeightForViewModel(_ viewModel: VM, constrainedToWidth width: CGFloat) -> CGFloat {
        let imageHeight = cellImageHeightForViewModel(viewModel, constrainedToWidth: width)
        let infoHeight = cellInfoHeightForViewModel(viewModel, constrainedToWidth: width)
        return imageHeight + infoHeight
    }
}
