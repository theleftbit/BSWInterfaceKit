//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

public class ScrollableStackView: UIScrollView {
    
    private let stackView = UIStackView()
    
    public init(axis: UILayoutConstraintAxis = .Vertical,
                alignment: UIStackViewAlignment = .Fill) {
        super.init(frame: CGRectZero)
        
        stackView.axis = axis
        stackView.alignment = alignment

        addSubview(stackView)

        stackView.fillSuperview()
        
        switch axis {
        case .Horizontal:
            stackView.heightAnchor.constraintEqualToAnchor(heightAnchor).active = true
        case .Vertical:
            stackView.widthAnchor.constraintEqualToAnchor(widthAnchor).active = true
        }
        
        clipsToBounds = true
    }

    public func addArrangedSubview(subview: UIView, layoutMargins: UIEdgeInsets) {

        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let dummyView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layoutMargins = layoutMargins
            return view
        }()
        
        dummyView.addSubview(subview)

        subview.topAnchor.constraintEqualToAnchor(dummyView.layoutMarginsGuide.topAnchor).active = true
        subview.bottomAnchor.constraintEqualToAnchor(dummyView.layoutMarginsGuide.bottomAnchor).active = true

        //If the subview will be used for text layout, use readableContentGuide instead
        let layoutGuideX: UILayoutGuide
        if subview.isKindOfClass(UILabel) || subview.isKindOfClass(UITextView) {
            layoutGuideX = dummyView.readableContentGuide
        } else {
            layoutGuideX = dummyView.layoutMarginsGuide
        }

        subview.leadingAnchor.constraintEqualToAnchor(layoutGuideX.leadingAnchor).active = true
        subview.trailingAnchor.constraintEqualToAnchor(layoutGuideX.trailingAnchor).active = true

        stackView.addArrangedSubview(dummyView)
    }
    
    public func addArrangedSubview(subview: UIView) {
        stackView.addArrangedSubview(subview)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override class func requiresConstraintBasedLayout() -> Bool {
        return true
    }
    
    public func viewAtIndex(index: Int) -> UIView? {
        return stackView.arrangedSubviews[safe: index]
    }
    
    public func indexOfView(view: UIView) -> Int? {
        return stackView.arrangedSubviews.indexOf(view)
    }

    public func removeAllArrangedViews() {
        stackView.removeAllArrangedSubviews()
    }
}
