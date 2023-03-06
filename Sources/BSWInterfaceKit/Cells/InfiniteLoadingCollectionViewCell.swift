
#if canImport(UIKit)

import UIKit

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

#endif
