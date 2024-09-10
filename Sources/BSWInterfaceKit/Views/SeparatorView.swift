#if canImport(UIKit.UIView)

import UIKit

@available(iOS 17, *)
#Preview {
    return SeparatorView()
}

/// This `UIView` subclass can be used as a horizontal separator to divide logical parts of your view.
public class SeparatorView: UIView {
    public init(color: UIColor = .separator) {
        super.init(frame: .zero)
        let separatorView = UIView()
        separatorView.backgroundColor = color
        addAutolayoutSubview(separatorView)
        separatorView.pinToSuperview()
        NSLayoutConstraint.activate([
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

#endif
