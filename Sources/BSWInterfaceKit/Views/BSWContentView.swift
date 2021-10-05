#if canImport(UIKit)

import UIKit

open class BSWContentView<T: UIContentConfiguration>: UIView, UIContentView {
    
    public var configuration: UIContentConfiguration {
        didSet {
            configureFor(configuration: typedConfiguration)
            setNeedsLayout()
        }
    }
    
    public var typedConfiguration: T {
        get { configuration as! T }
        set { configuration = newValue }
    }
    
    public init(configuration: T) {
        defer { configureFor(configuration: configuration) }
        self.configuration = configuration
        super.init(frame: .zero)
    }
    
    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    open func configureFor(configuration: T) {
        fatalError()
    }
}

public extension BSWContentView where T: Hashable {
    static func defaultCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewCell, T> {
        return .init { cell, _, itemIdentifier in
            cell.contentConfiguration = itemIdentifier
        }
    }
}
#endif
