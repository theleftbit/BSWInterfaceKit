//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import UIKit
import Cartography

//MARK: ViewModel

public protocol PolaroidPicture {
    var imageURL: String { get }
    var width: Int { get }
    var height: Int { get }
    var hexColor: String { get }
}

public protocol PolaroidCellViewModel {
    var cellImage: PolaroidPicture { get }
    var cellTitle: NSAttributedString { get }
    var cellDetails: NSAttributedString { get }
}

//MARK: Cells

@available(iOS 8.0, *)
public class PolaroidCollectionViewCell: UICollectionViewCell {
    
    public typealias T = PolaroidCellViewModel
    
    private var detailSubview: UIView!
    
    private let cellImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .ScaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private static let MaxImageHeightProportion = CGFloat(1.4)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.bsw_cancelImageLoadFromURL()
        cellImageView.image = nil
    }
    
    private func setupWithSubviewType(type: UIView.Type) {
        
        detailSubview = type.init()
        
        contentView.addSubview(cellImageView)
        contentView.addSubview(detailSubview)
        
        setupConstraints()
        setupRoundedCorners()
        
        contentView.layoutIfNeeded()
    }
    
    /// This is a placeholder constraint to make sure that when doing the final
    /// layout for the wanted viewModel, the image height is not compressed
    private var imageHeightConstraint: NSLayoutConstraint!
    
    private func setupConstraints() {
        constrain(cellImageView, detailSubview, self.contentView) { cellImageView, detailSubview, contentView in
            
            //Subview Layout
            cellImageView.top == contentView.top
            cellImageView.leading == contentView.leading
            cellImageView.trailing == contentView.trailing
            cellImageView.bottom == detailSubview.top
            detailSubview.leading == contentView.leading
            detailSubview.trailing == contentView.trailing
            detailSubview.bottom == contentView.bottom
            
            self.imageHeightConstraint = (cellImageView.height == 80 ~ 999)
        }
    }
    
    private func setupRoundedCorners() {
        contentView.roundCorners()
    }
    
    private func setupShadow(opacity: CGFloat) {
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSizeMake(0, 1)
        layer.shadowOpacity = Float(opacity)
        layer.shadowRadius = CGFloat(2)
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
    }
    
    public func configureFor(viewModel viewModel: PolaroidCellViewModel) {
        
        //Set the image
        if let url = NSURL(string: viewModel.cellImage.imageURL) {
            cellImageView.bsw_setImageFromURL(url)
        }

        // Make sure that the image is not compressed when doing the final
        // layout by setting it's height to the wanted for a given height
        imageHeightConstraint.constant = PolaroidCollectionViewCell.cellImageHeightForViewModel(viewModel, constrainedToWidth: CGRectGetWidth(contentView.frame))
        layoutIfNeeded()
    }
}

@available(iOS 8.0, *)
public class PolaroidBasicCollectionViewCell: PolaroidCollectionViewCell, ViewModelReusable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWithSubviewType(PolaroidCollectionCellBasicInfoView.self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        let detailSubview = self.detailSubview as! PolaroidCollectionCellBasicInfoView
        detailSubview.setTitle()
    }
    
    override public func configureFor(viewModel viewModel: PolaroidCellViewModel) {
        
        super.configureFor(viewModel: viewModel)
        
        //Set the basic info
        let detailSubview = self.detailSubview as! PolaroidCollectionCellBasicInfoView
        detailSubview.setTitle(viewModel.cellTitle, subtitle: viewModel.cellDetails)
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
        stackView.axis = .Vertical
        stackView.alignment = .Fill
        stackView.spacing = Stylesheet.margin(.Smallest)
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(title: NSAttributedString? =  nil, subtitle: NSAttributedString? = nil) {
        titleLabel.attributedText = title
        detailLabel.attributedText = subtitle
    }
    
    private func setup() {
        backgroundColor = UIColor.whiteColor()
        setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
        
        addSubview(stackView)
        constrain(stackView) { stackView in
            stackView.edges == inset(stackView.superview!.edges, Stylesheet.margin(.Medium)) 
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(detailLabel)
    }
}

//MARK: - Height calculation

@available(iOS 8.0, *)
extension PolaroidCollectionViewCell {
    
    private struct PolaroidCollectionViewCellHeightCalculator {
        private static let BasicInfoView = PolaroidCollectionCellBasicInfoView()
    }
    
    private static func cellImageHeightForViewModel(viewModel: PolaroidCellViewModel, constrainedToWidth width: CGFloat) -> CGFloat {
        let maxImageHeight = PolaroidCollectionViewCell.MaxImageHeightProportion * width
        let imageHeight = min(maxImageHeight, width * CGFloat(viewModel.cellImage.height) / CGFloat(viewModel.cellImage.width))
        return imageHeight
    }
    
    private static func cellInfoHeightForViewModel(viewModel: PolaroidCellViewModel, constrainedToWidth width: CGFloat) -> CGFloat {
        let infoView = PolaroidCollectionViewCellHeightCalculator.BasicInfoView
        infoView.setTitle(viewModel.cellTitle, subtitle: viewModel.cellDetails)
        let height = infoView.systemLayoutSizeFittingSize(CGSize(width: width, height: 0),
                                                          withHorizontalFittingPriority: UILayoutPriorityRequired,
                                                          verticalFittingPriority: UILayoutPriorityFittingSizeLevel
            ).height
        return height
    }
    
    static public func cellHeightForViewModel(viewModel: PolaroidCellViewModel, constrainedToWidth width: CGFloat) -> CGFloat {
        guard viewModel.cellImage.width != 0 && viewModel.cellImage.height != 0 else {
            return width
        }
        
        let imageHeight = cellImageHeightForViewModel(viewModel, constrainedToWidth: width)
        let infoHeight = cellInfoHeightForViewModel(viewModel, constrainedToWidth: width)
        
        return imageHeight + infoHeight
    }
}
