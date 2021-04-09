
#if canImport(UIKit)

import UIKit

@available(iOS 14, *)
open class InfiniteLoadingCollectionViewCell: UICollectionViewListCell {

    public let Margins: UIEdgeInsets = .init(uniform: 8)
    public let loadingView = UIActivityIndicatorView(style: .defaultStyle)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundConfiguration = .clear()
        accessories = []
        contentView.addAutolayoutSubview(loadingView)
        let heightAnchor = loadingView.heightAnchor.constraint(equalToConstant: 16)
        heightAnchor.priority = .init(999)
        NSLayoutConstraint.activate([
            heightAnchor,
            loadingView.widthAnchor.constraint(equalTo: loadingView.heightAnchor),
            loadingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Margins.top),
            contentView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Margins.bottom),
        ])
    }

    public required init?(coder: NSCoder) {
        fatalError("not implemented")
    }
    
    open func startAnimating() {
        loadingView.startAnimating()
    }
}

public class InfiniteLoadingCollectionViewFooter: UICollectionReusableView, ViewModelReusable, CollectionViewInfiniteFooter {
    
    public let activityIndicator = UIActivityIndicatorView(style: .defaultStyle)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addAutolayoutSubview(activityIndicator)
        let constraints = [
            activityIndicator.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            activityIndicator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor)
            ]
        constraints.forEach({ $0.priority = .init(999) })
        NSLayoutConstraint.activate(constraints)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureFor(viewModel: Void) {

    }
    
    public func startAnimating() {
        activityIndicator.startAnimating()
    }    
}

#endif
