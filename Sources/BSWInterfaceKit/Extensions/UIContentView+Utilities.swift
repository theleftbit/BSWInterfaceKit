#if canImport(UIKit)

import UIKit

public extension UIContentView {
    
    static func defaultCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, UIContentConfiguration> {
        return .init { cell, _, itemIdentifier in
            cell.contentConfiguration = itemIdentifier
        }
    }

    static func defaultHeaderRegistration<T: UIContentConfiguration>(configuration: T) -> UICollectionView.SupplementaryRegistration<ContentHeaderView<T>> {
        return .init(elementKind: UICollectionView.SupplementaryViewKind.header.toUIKit()) { supplementaryView, elementKind, indexPath in
            supplementaryView.configuration = configuration
        }
    }
}

/// MARK: Auxiliary views

public class ContentHeaderView<T: UIContentConfiguration>: UICollectionReusableView {
    
    var view: (UIContentView & UIView)!
    
    public var configuration: T! {
        didSet {
            if let prevView = view {
                prevView.configuration = configuration
            } else {
                view = configuration.makeContentView()
                addSubview(view)
                view.pinToSuperview()
            }
        }
    }
}

#endif
