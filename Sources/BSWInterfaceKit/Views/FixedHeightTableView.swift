//
//  Created by Pierluigi Cifani on 10/03/2020.
//

#if canImport(UIKit)

import UIKit

/// This subclass of UITableView will force it's height to be of it's
/// `contentSize.height`. Use wisely when building your UIs
public class FixedHeightTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        heightConstraintForTableView = self.heightAnchor.constraint(equalToConstant: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var contentSize: CGSize {
        didSet {
            guard contentSize != oldValue,
                contentSize.height > 0 else { return }
            self.heightConstraintForTableView.constant = contentSize.height
            self.heightConstraintForTableView.isActive = true
        }
    }
    
    //MARK: Private
    
    private var heightConstraintForTableView: NSLayoutConstraint!
}

#endif
