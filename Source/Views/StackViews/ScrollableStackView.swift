//
//  Created by Pierluigi Cifani on 06/05/16.
//  Copyright © 2016 Blurred Software SL. All rights reserved.
//

import Foundation

open class ScrollableStackView: UIScrollView {
    
    fileprivate let stackView = UIStackView()
    
    public init(axis: UILayoutConstraintAxis = .vertical,
                alignment: UIStackViewAlignment = .leading) {
        super.init(frame: CGRect.zero)
        
        stackView.axis = axis
        stackView.alignment = alignment

        addSubview(stackView)

        stackView.fillSuperview()
        
        switch axis {
        case .horizontal:
            stackView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
            alwaysBounceHorizontal = true
        case .vertical:
            stackView.widthAnchor.constraint(equalTo: widthAnchor).isActive = true
            alwaysBounceVertical = true
        }
        
        clipsToBounds = true
    }

    open func addArrangedSubview(_ subview: UIView, layoutMargins: UIEdgeInsets) {

        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let dummyView: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layoutMargins = layoutMargins
            return view
        }()
        
        dummyView.addSubview(subview)

        subview.topAnchor.constraint(equalTo: dummyView.layoutMarginsGuide.topAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: dummyView.layoutMarginsGuide.bottomAnchor).isActive = true

        //If the subview will be used for text layout, use readableContentGuide instead
        let layoutGuideX: UILayoutGuide
        if subview.isKind(of: UILabel.self) || subview.isKind(of: UITextView.self) {
            layoutGuideX = dummyView.readableContentGuide
        } else {
            layoutGuideX = dummyView.layoutMarginsGuide
        }

        subview.leadingAnchor.constraint(equalTo: layoutGuideX.leadingAnchor).isActive = true
        subview.trailingAnchor.constraint(equalTo: layoutGuideX.trailingAnchor).isActive = true

        stackView.addArrangedSubview(dummyView)
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
        return stackView.arrangedSubviews.index(of: view)
    }

    open func removeAllArrangedViews() {
        stackView.removeAllArrangedSubviews()
    }
}
