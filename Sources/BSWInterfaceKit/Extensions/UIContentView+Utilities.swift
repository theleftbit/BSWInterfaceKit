#if canImport(UIKit)

import UIKit


/// This protocol abstracts away types that provide accesibility identifiers, useful for UI Tests
public protocol AccessibilityLabelProvider {
    var accessibilityIdentifier: String? { get }
}

public extension UIContentView {
        
    
    /// Creates a `UICollectionView.CellRegistration` for a `UIContentView` to be used as a `UICollectionView`'s cell
    /// - Parameter backgroundConfiguration: An optional `UIBackgroundConfiguration` that defines what the background is on collection views.
    /// - Returns: the `UICollectionView.CellRegistration` ready to be used.
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
    
    /// Creates a `UICollectionView.SupplementaryRegistration` for a `UIContentView` to be used as a `UICollectionView`'s header
    /// - Parameter configuration: The `UIContentConfiguration` that represents the header
    /// - Returns: a `UICollectionView.SupplementaryRegistration` ready to be used.
    static func defaultHeaderRegistration<T: UIContentConfiguration>(configuration: T) -> UICollectionView.SupplementaryRegistration<ContentReusableView<T>> {
        return .init(elementKind: UICollectionView.SupplementaryViewKind.header.toUIKit()) { supplementaryView, elementKind, indexPath in
            supplementaryView.configuration = configuration
        }
    }
    
    /// Creates a `UICollectionView.SupplementaryRegistration` for a `UIContentView` to be used as a `UICollectionView`'s footer
    /// - Parameter configuration: The `UIContentConfiguration` that represents the footer
    /// - Returns: a `UICollectionView.SupplementaryRegistration` ready to be used.
    static func defaultFooterRegistration<T: UIContentConfiguration>(configuration: T) -> UICollectionView.SupplementaryRegistration<ContentReusableView<T>> {
        return .init(elementKind: UICollectionView.SupplementaryViewKind.footer.toUIKit()) { supplementaryView, elementKind, indexPath in
            supplementaryView.configuration = configuration
        }
    }
}

/// MARK: Auxiliary views

public class ContentReusableView<T: UIContentConfiguration>: UICollectionReusableView {
    
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
