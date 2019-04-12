//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

@objc(BSWScrollableStackView)
open class ScrollableStackView: UIScrollView {

    private let stackView = UIStackView()

    public init(axis: NSLayoutConstraint.Axis = .vertical,
                alignment: UIStackView.Alignment = .leading) {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = axis
        self.alignment = alignment

        addSubview(stackView)
        stackView.pinToSuperview()

        switch axis {
        case .horizontal:
            stackView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            alwaysBounceHorizontal = true
        case .vertical:
            stackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            alwaysBounceVertical = true
        @unknown default:
            fatalError()
        }

        clipsToBounds = true
    }

    open func addArrangedSubview(_ subview: UIView, layoutMargins: UIEdgeInsets) {
        stackView.addArrangedSubview(subview, layoutMargins: layoutMargins)
    }

    open func addArrangedSubview(_ subview: UIView) {
        stackView.addArrangedSubview(subview)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override class var requiresConstraintBasedLayout : Bool {
        return true
    }

    open func viewAtIndex(_ index: Int) -> UIView? {
        return stackView.arrangedSubviews[safe: index]
    }

    open func indexOfView(_ view: UIView) -> Int? {
        return stackView.arrangedSubviews.firstIndex(of: view)
    }

    open func removeAllArrangedViews() {
        stackView.removeAllArrangedSubviews()
    }

    override open var layoutMargins: UIEdgeInsets {
        get {
            return stackView.layoutMargins
        }
        set {
            stackView.layoutMargins = newValue
            stackView.isLayoutMarginsRelativeArrangement = true
        }
    }

    open var spacing: CGFloat {
        get {
            return stackView.spacing
        } set {
            stackView.spacing = newValue
        }
    }
    
    open var alignment: UIStackView.Alignment {
        get {
            return stackView.alignment
        } set {
            stackView.alignment = newValue
        }
    }

    open var distribution: UIStackView.Distribution {
        get {
            return stackView.distribution
        } set {
            stackView.distribution = newValue
        }
    }
    
    open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return stackView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
}
