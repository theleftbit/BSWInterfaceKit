
#if canImport(UIKit)

import UIKit

@available(iOS 13.0, *)
public extension UICollectionViewCompositionalLayout {
    
    static func simpleListWith(estimatedHeight: CGFloat, spacing: CGFloat) -> UICollectionViewLayout {
        /// This layout describes a list with variable height for the cells.
        /// https://twitter.com/piercifani/status/1317069319893864449
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(estimatedHeight)
            )
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            ),
            subitems: [item]
        )
        group.interItemSpacing = .fixed(spacing)
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(
            top: spacing, leading: spacing, bottom: spacing, trailing: spacing
        )
        return UICollectionViewCompositionalLayout(section: section)
    }
}

#endif
