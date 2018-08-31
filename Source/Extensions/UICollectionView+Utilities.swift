//
//  Created by Pierluigi Cifani on 31/03/2017.
//

import UIKit

extension UICollectionView {
    public func registerReusableCell<T: UICollectionViewCell>(_: T.Type) where T: ViewModelReusable {
        switch T.reuseType {
        case .classReference(let className):
            self.register(className, forCellWithReuseIdentifier: T.reuseIdentifier)
        case .nib(let nib):
            self.register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }

    public func dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T where T: ViewModelReusable {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Did you register this cell?")
        }
        return cell
    }

    public enum SupplementaryViewKind {
        case footer
        case header

        func toUIKit() -> String {
            switch self {
            case .footer:
                return UICollectionView.elementKindSectionFooter
            case .header:
                return UICollectionView.elementKindSectionHeader
            }
        }
    }

    public func registerSupplementaryView<T: UICollectionReusableView>(_: T.Type, kind: SupplementaryViewKind) where T: ViewModelReusable {
        switch T.reuseType {
        case .classReference(let className):
            self.register(className, forSupplementaryViewOfKind: kind.toUIKit(), withReuseIdentifier: T.reuseIdentifier)
        case .nib(let nib):
            self.register(nib, forSupplementaryViewOfKind: kind.toUIKit(), withReuseIdentifier: T.reuseIdentifier)
        }
    }

    public func dequeueSupplementaryView<T: UICollectionReusableView>(indexPath: IndexPath, kind: SupplementaryViewKind) -> T where T: ViewModelReusable {
        guard let reusableView = self.dequeueReusableSupplementaryView(ofKind: kind.toUIKit(), withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Did you register this ViewModelReusable?")
        }
        return reusableView
    }

    public func selectItemsAt(indexSet: IndexSet) {
        indexSet.forEach {
            self.selectItem(at: IndexPath(item: $0, section: 0), animated: true, scrollPosition: .left)
        }
    }
}

