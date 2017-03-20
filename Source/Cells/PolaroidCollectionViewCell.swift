//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit

//MARK: ViewModel

public struct PolaroidCellViewModel {
    public let cellImage: Photo
    public let cellTitle: NSAttributedString
    public let cellDetails: NSAttributedString
}

//MARK: Cells

@available(iOS 8.0, *)
open class PolaroidCollectionViewCell: UICollectionViewCell, ViewModelReusable {
    
    fileprivate let detailSubview = PolaroidCollectionCellBasicInfoView()
    
    fileprivate let cellImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate static let MaxImageHeightProportion = CGFloat(1.4)
    
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
        cellImageView.bsw_cancelImageLoadFromURL()
        cellImageView.image = nil
    }
    
    fileprivate func setup() {        
        contentView.addAutolayoutSubview(cellImageView)
        contentView.addAutolayoutSubview(detailSubview)
        
        setupConstraints()
        setupRoundedCorners()
        
        contentView.layoutIfNeeded()
    }
    
    /// This is a placeholder constraint to make sure that when doing the final
    /// layout for the wanted viewModel, the image height is not compressed
    fileprivate var imageHeightConstraint: NSLayoutConstraint!
    
    fileprivate func setupConstraints() {
        var constraints = [NSLayoutConstraint]()

        imageHeightConstraint = cellImageView.heightAnchor.constraint(equalToConstant: 80)
        imageHeightConstraint.priority = 999

        constraints.append(imageHeightConstraint)
        constraints.append(cellImageView.topAnchor.constraint(equalTo: contentView.topAnchor))
        constraints.append(cellImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor))
        constraints.append(cellImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor))
        constraints.append(cellImageView.bottomAnchor.constraint(equalTo: detailSubview.bottomAnchor))
        constraints.append(detailSubview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor))
        constraints.append(detailSubview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor))
        constraints.append(detailSubview.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))

        NSLayoutConstraint.activate(constraints)
    }
    
    fileprivate func setupRoundedCorners() {
        contentView.roundCorners()
    }
    
    fileprivate func setupShadow(_ opacity: CGFloat) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowOpacity = Float(opacity)
        layer.shadowRadius = CGFloat(2)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    open func configureFor(viewModel: PolaroidCellViewModel) {

        //Set the basic info
        detailSubview.setTitle(viewModel.cellTitle, subtitle: viewModel.cellDetails)

        //Set the image
        cellImageView.bsw_setPhoto(viewModel.cellImage)
        
        // Make sure that the image is not compressed when doing the final
        // layout by setting it's height to the wanted for a given height
        imageHeightConstraint.constant = PolaroidCollectionViewCell.cellImageHeightForViewModel(viewModel, constrainedToWidth: contentView.frame.width)
        setNeedsLayout()
    }
}

//MARK: - Subviews

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
        stackView.translatesAutoresizingMaskIntoConstraints = false
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
        setContentCompressionResistancePriority(UILayoutPriorityRequired, for: .vertical)
        
        addSubview(stackView)
        stackView.fillSuperview(withMargin: Stylesheet.margin(.medium))
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(detailLabel)
    }
}

//MARK: - Height calculation

@available(iOS 8.0, *)
extension PolaroidCollectionViewCell {
    
    fileprivate struct PolaroidCollectionViewCellHeightCalculator {
        fileprivate static let BasicInfoView = PolaroidCollectionCellBasicInfoView()
    }
    
    fileprivate static func cellImageHeightForViewModel(_ viewModel: PolaroidCellViewModel, constrainedToWidth width: CGFloat) -> CGFloat {
        let maxImageHeight = PolaroidCollectionViewCell.MaxImageHeightProportion * width
        let imageSize = viewModel.cellImage.size ?? CGSize(width: width, height: width)
        let imageHeight = min(maxImageHeight, width * CGFloat(imageSize.height) / CGFloat(imageSize.width))
        return imageHeight
    }
    
    fileprivate static func cellInfoHeightForViewModel(_ viewModel: PolaroidCellViewModel, constrainedToWidth width: CGFloat) -> CGFloat {
        let infoView = PolaroidCollectionViewCellHeightCalculator.BasicInfoView
        infoView.setTitle(viewModel.cellTitle, subtitle: viewModel.cellDetails)
        let height = infoView.systemLayoutSizeFitting(CGSize(width: width, height: 0),
                                                          withHorizontalFittingPriority: UILayoutPriorityRequired,
                                                          verticalFittingPriority: UILayoutPriorityFittingSizeLevel
            ).height
        return height
    }
    
    static public func cellHeightForViewModel(_ viewModel: PolaroidCellViewModel, constrainedToWidth width: CGFloat) -> CGFloat {
        let imageHeight = viewModel.cellImage.size == .none ? width : cellImageHeightForViewModel(viewModel, constrainedToWidth: width)
        let infoHeight = cellInfoHeightForViewModel(viewModel, constrainedToWidth: width)
        
        return imageHeight + infoHeight
    }
}
