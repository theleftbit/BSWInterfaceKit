//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

//MARK: ViewModel

public protocol PolaroidCellViewModel {
    var cellImage: Photo { get }
    var cellTitle: NSAttributedString { get }
    var cellDetails: NSAttributedString { get }
}

//MARK: Cells

@available(iOS 8.0, *)
open class PolaroidCollectionViewCell: UICollectionViewCell, ViewModelReusable {
    
    public typealias T = PolaroidCellViewModel
    
    fileprivate var detailSubview: PolaroidCollectionCellBasicInfoView!
    
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
        
        detailSubview = PolaroidCollectionCellBasicInfoView()
        
        contentView.addSubview(cellImageView)
        contentView.addSubview(detailSubview)
        
        setupConstraints()
        setupRoundedCorners()
        
        contentView.layoutIfNeeded()
    }
    
    /// This is a placeholder constraint to make sure that when doing the final
    /// layout for the wanted viewModel, the image height is not compressed
    fileprivate var imageHeightConstraint: NSLayoutConstraint!
    
    fileprivate func setupConstraints() {
        constrain(cellImageView, detailSubview, self.contentView) { cellImageView, detailSubview, contentView in
            
            //Subview Layout
            cellImageView.top == contentView.top
            cellImageView.leading == contentView.leading
            cellImageView.trailing == contentView.trailing
            cellImageView.bottom == detailSubview.top
            detailSubview.leading == contentView.leading
            detailSubview.trailing == contentView.trailing
            detailSubview.bottom == contentView.bottom
            
            self.imageHeightConstraint = (cellImageView.height == 80)
        }
        
        //TODO: Move to the constrain block when they fix Cartography
        self.imageHeightConstraint.priority = 999
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
        constrain(stackView) { stackView in
            stackView.edges == inset(stackView.superview!.edges, Stylesheet.margin(.medium)) 
        }
        
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
