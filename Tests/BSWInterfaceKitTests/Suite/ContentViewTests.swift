#if canImport(UIKit)
/*
import BSWInterfaceKit
import XCTest

class ContentViewTests: BSWSnapshotTest {
    
    func testLayout() throws {
        let vc = ViewController()
        waitABitAndVerify(viewController: vc, testDarkMode: false)
    }
}

import UIKit

private class ViewController: UIViewController {

    var dataSource: UICollectionViewDiffableDataSource<Section, CustomCell.Configuration.ID>!
    
    override func loadView() {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: {
            var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
            config.backgroundColor = .systemGroupedBackground
            config.headerMode = .supplementary
            return UICollectionViewCompositionalLayout.list(using: config)
        }())
        let items: [CustomCell.Configuration] = [
            .init(id: UUID(), title: "Hello"),
            .init(id: UUID(), title: "World"),
            .init(id: UUID(), title: "I really like this")
        ]
        let cellProvider = CustomCell.View.defaultCellRegistration()
        let headerProvider = CustomHeader.View.defaultHeaderRegistration(configuration: CustomHeader.Configuration(title: "Hello, it's me"))
        
        dataSource = .init(collectionView: collectionView) { collectionView, indexPath, _ in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellProvider,
                for: indexPath,
                item: items[indexPath.item]
            )
        }
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(using: headerProvider, for: indexPath)
            } else {
                return nil
            }
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
    
    
    enum CustomCell {
        
        struct Configuration: UIContentConfiguration, Identifiable {
            
            init(id: UUID, title: String, state: UICellConfigurationState? = nil) {
                self.id = id
                self.title = title
                self.state = state
            }
            
            let id: UUID
            let title: String
            private(set) var state: UICellConfigurationState?
            
            func makeContentView() -> UIView & UIContentView {
                View(configuration: self)
            }
            
            func updated(for state: UIConfigurationState) -> Configuration {
                var mutableCopy = self
                if let cellState = state as? UICellConfigurationState {
                    mutableCopy.state =  cellState
                }
                return mutableCopy
            }
        }
        
        class View: UIView, UIContentView {

            let label = UILabel()
            let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
            var configuration: UIContentConfiguration

            init(configuration: CustomCell.Configuration) {
                self.configuration = configuration
                super.init(frame: .zero)
                backgroundColor = .systemBackground
                let stackView = UIStackView(arrangedSubviews: [
                    label,
                    imageView
                ])
                addAutolayoutSubview(stackView)
                stackView.pinToSuperview()
                stackView.layoutMargins = .init(uniform: 8)
                stackView.isLayoutMarginsRelativeArrangement = true
                configureFor(configuration: configuration)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            func configureFor(configuration: CustomCell.Configuration) {
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
    
    enum CustomHeader {
        
        struct Configuration: UIContentConfiguration {
            
            let title: String
            
            func makeContentView() -> UIView & UIContentView {
                View(configuration: self)
            }
            
            func updated(for state: UIConfigurationState) -> Configuration {
                return self
            }
        }
        
        class View: UIView, UIContentView {
            
            let label = UILabel()
            var configuration: UIContentConfiguration {
                didSet {
                    configureFor(configuration: configuration as! Configuration)
                }
            }

            init(configuration: Configuration) {
                self.configuration = configuration
                super.init(frame: .zero)
                addAutolayoutSubview(label)
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: topAnchor, constant: 6),
                    label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
                    label.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
                ])
                configureFor(configuration: configuration)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            func configureFor(configuration: Configuration) {
                label.text = configuration.title
            }
        }

    }
}
 */
#endif
