#if canImport(UIKit)

import BSWInterfaceKit
import XCTest

class ContentViewTests: BSWSnapshotTest {
    func testLayout() throws {
        try XCTSkipIf(true, nil)
        let vc = ViewController()
        waitABitAndVerify(viewController: vc, testDarkMode: false)
    }
}

import UIKit

private class ViewController: UIViewController {

    var dataSource: UICollectionViewDiffableDataSource<Section, CustomCellContentConfiguration.ID>!
    
    override func loadView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: {
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.backgroundColor = .systemGroupedBackground
            return UICollectionViewCompositionalLayout.list(using: config)
        }())
        let items: [CustomCellContentConfiguration] = [
            .init(id: UUID(), title: "Hello"),
            .init(id: UUID(), title: "World"),
            .init(id: UUID(), title: "I really like this")
        ]
        let cellProvider = CustomCell.defaultCellRegistration()
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, _ in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellProvider,
                for: indexPath,
                item: items[indexPath.item]
            )
        }
        view = collectionView
        
        var snapshot = dataSource.snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(items.map({ $0.id }), toSection: .main)
        dataSource.apply(snapshot)
        
        collectionView.selectItem(at: .init(item: 0, section: 0), animated: false, scrollPosition: .init())
        collectionView.allowsMultipleSelection = true
    }
        
    enum Section {
        case main
    }
    
    struct CustomCellContentConfiguration: UIContentConfiguration, Identifiable {
        
        init(id: UUID, title: String, state: UICellConfigurationState? = nil) {
            self.id = id
            self.title = title
            self.state = state
        }
        
        let id: UUID
        let title: String
        private(set) var state: UICellConfigurationState?
        
        func makeContentView() -> UIView & UIContentView {
            CustomCell(configuration: self)
        }
        
        func updated(for state: UIConfigurationState) -> CustomCellContentConfiguration {
            var mutableCopy = self
            if let cellState = state as? UICellConfigurationState {
                mutableCopy.state =  cellState
            }
            return mutableCopy
        }
    }

    class CustomCell: BSWContentView<CustomCellContentConfiguration> {
        
        let label = UILabel()
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))

        override init(configuration: CustomCellContentConfiguration) {
            super.init(configuration: configuration)
            backgroundColor = .systemBackground
            let stackView = UIStackView(arrangedSubviews: [
                label,
                imageView
            ])
            addAutolayoutSubview(stackView)
            stackView.pinToSuperview()
            stackView.layoutMargins = .init(uniform: 8)
            stackView.isLayoutMarginsRelativeArrangement = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func configureFor(configuration: CustomCellContentConfiguration) {
            label.text = configuration.title
            if let cellState = configuration.state {
                backgroundColor = cellState.isHighlighted ? .systemGray3 : .systemBackground
                imageView.isHidden = !(cellState.isSelected)
            } else {
                backgroundColor = .systemBackground
                imageView.isHidden = true
            }
        }
    }
}
#endif
