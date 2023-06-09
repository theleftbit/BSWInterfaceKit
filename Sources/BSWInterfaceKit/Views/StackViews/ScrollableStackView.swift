//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//
#if canImport(UIKit)

import UIKit

@objc(BSWScrollableStackView)
/**
 This scrollView subclass creates a stackView that scrolls along the specified axis.

 Use this view to layout content that's bigger than the user's screen, which will allow it to scroll. A sample use would be:
 
 ```
 override func loadView() {
    view = UIView()
    let scrollableStackView = ScrollableStackView(axis: .vertical, alignment: .fill)
    view.addAutolayoutSubview(scrollableStackView)
    scrollableStackView.keyboardDismissMode = .onDrag
    scrollableStackView.pinToSuperview()
    scrollableStackView.layoutMargins = .init(uniform: 16)
    scrollableStackView.spacing = 16
    scrollableStackView.addArrangedSubview(...)
    scrollableStackView.addArrangedSubview(...)
 }
 ```
*/
open class ScrollableStackView: UIScrollView {
    
    private let stackView = UIStackView()
    
    /// Initializes a new `ScrollableStackView`
    /// - Parameters:
    ///   - axis: The axis that will scroll
    ///   - alignment: the alignment of the stackView
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
    
    /// Adds an arranged subview to the stackView
    /// - Parameters:
    ///   - subview: The view to add to the array of views arranged by the stack.
    ///   - layoutMargins: Any margin that is needed.
    open func addArrangedSubview(_ subview: UIView, layoutMargins: UIEdgeInsets) {
        stackView.addArrangedSubview(subview, layoutMargins: layoutMargins)
    }
    
    /// Adds an arranged subview to the stackView
    ///   - subview: The view to add to the array of views arranged by the stack.
    open func addArrangedSubview(_ subview: UIView) {
        stackView.addArrangedSubview(subview)
    }
    
    /// Adds the provided view to the array of arranged subviews at the specified index.
    /// - Parameters:
    ///   - view: The view to add to the array of views arranged by the stack.
    ///   - index: The index where the stack inserts the new view in its arrangedSubviews array. This value must not be greater than the number of views currently in this array. If the index is out of bounds, this method throws an internalInconsistencyException exception.
    open func insertArrangedSubview(_ view: UIView, at index: Int) {
        stackView.insertArrangedSubview(view, at: index)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override class var requiresConstraintBasedLayout : Bool {
        return true
    }
    
    /// Applies custom spacing after the specified view.
    open func setCustomSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) {
        stackView.setCustomSpacing(spacing, after: arrangedSubview)
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
    
    open var arrangedSubviews: [UIView] {
        stackView.arrangedSubviews
    }
    
    open override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        return stackView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
    }
}
#endif
