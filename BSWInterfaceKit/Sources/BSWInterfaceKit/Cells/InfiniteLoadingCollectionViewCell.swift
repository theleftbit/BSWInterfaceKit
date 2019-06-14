
import UIKit

public class InfiniteLoadingCollectionViewFooter: UICollectionReusableView, ViewModelReusable, CollectionViewInfiniteFooter {
    
    public let activityIndicator = UIActivityIndicatorView(style: .gray)
    
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
