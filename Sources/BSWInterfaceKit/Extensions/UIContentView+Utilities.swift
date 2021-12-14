#if canImport(UIKit)

import UIKit

public protocol AccessibilityLabelProvider {
    var accessibilityIdentifier: String? { get }
}

public extension UIContentView {
        
    static func defaultCellRegistration(backgroundConfiguration: UIBackgroundConfiguration? = nil) -> UICollectionView.CellRegistration<UICollectionViewCell, UIContentConfiguration> {
        return .init { cell, _, itemIdentifier in
            cell.contentConfiguration = itemIdentifier
            if let backgroundConfiguration = backgroundConfiguration {
                cell.backgroundConfiguration = backgroundConfiguration
            }
            
            if let accessibleConfiguration = itemIdentifier as? AccessibilityLabelProvider {
                cell.accessibilityIdentifier = accessibleConfiguration.accessibilityIdentifier
            }
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
