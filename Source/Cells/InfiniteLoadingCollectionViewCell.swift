
import UIKit

public class InfiniteLoadingCollectionViewCell: UICollectionViewCell, ViewModelReusable {
    
    public let activityIndicator = UIActivityIndicatorView(style: .gray)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        contentView.addAutolayoutSubview(activityIndicator)
        activityIndicator.centerInSuperview()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureFor(viewModel: Void) {

    }
    
    static var preferredHeight: CGFloat {
        return 50
    }
}
