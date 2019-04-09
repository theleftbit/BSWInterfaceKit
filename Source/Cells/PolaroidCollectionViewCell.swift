//
//  Created by Pierluigi Cifani on 28/04/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

//MARK: Cells

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

    private let detailSubview = PolaroidCollectionCellBasicInfoView()
    
    private let cellImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    private let stackView = UIStackView()

    public static let MaxImageHeightProportion = CGFloat(2)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        stackView.addArrangedSubview(cellImageView)
        stackView.addArrangedSubview(detailSubview)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        contentView.addAutolayoutSubview(stackView)
        stackView.pinToSuperview()

        setupImageConstraint()
        setupRoundedCorners()
        layer.addShadow(opacity: 0.1, shadowRadius: 4)
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.backgroundColor = UIColor.clear
        cellImageView.cancelImageLoadFromURL()
        cellImageView.image = nil
    }

    /// This is a placeholder constraint to make sure that when doing the final
    /// layout for the wanted viewModel, the image height is not compressed
    private var imageHeightConstraint: NSLayoutConstraint!
    
    private func setupImageConstraint(multiplier: CGFloat = 1) {
        if let imageHeightConstraint = self.imageHeightConstraint {
            cellImageView.removeConstraint(imageHeightConstraint)
        }
        imageHeightConstraint = cellImageView.heightAnchor.constraint(equalTo: cellImageView.widthAnchor, multiplier: multiplier)
        NSLayoutConstraint.activate([imageHeightConstraint])
    }
    
    private func setupRoundedCorners() {
        contentView.roundCorners()
    }
    
    open func configureFor(viewModel: VM) {

        //Set the basic info
        detailSubview.setTitle(viewModel.cellTitle, subtitle: viewModel.cellDetails)

        //Set the image
        cellImageView.setPhoto(viewModel.cellImage)
        if let imageSize = viewModel.cellImage.size {
            let ratio = min(imageSize.height/imageSize.width, PolaroidCollectionViewCell.MaxImageHeightProportion)
            setupImageConstraint(multiplier: ratio)
        } else {
            setupImageConstraint()
        }
    }
}

//MARK: - Subviews

@objc(BSWPolaroidCollectionCellBasicInfoView)
public class PolaroidCollectionCellBasicInfoView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 2
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
    
    private func setup() {
        backgroundColor = .white
        addAutolayoutSubview(stackView)
        stackView.pinToSuperview()
        stackView.layoutMargins = UIEdgeInsets(uniform: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(detailLabel)
    }
}
