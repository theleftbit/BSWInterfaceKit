//
//  Created by Pierluigi Cifani on 28/03/2019.
//

#if canImport(Testing)

import UIKit
import BSWInterfaceKit
import Testing

class HorizontalPagedCollectionViewLayoutTests: BSWSnapshotTest {
        
    override init() {
        super.init()
        waitStrategy = .closestBSWTask
    }
    
    @Test
    func layout() async {
        let vc = ViewController(layout: HorizontalPagedCollectionViewLayout())
        await verify(viewController: vc, testDarkMode: false)
    }

    @Test
    func centeredLayout() async {
        let vc = PlanSelectorViewController()
        await verify(viewController: vc, testDarkMode: false)
    }

    @Test
    func availableWidthLayout() async {
        let vc = ViewController(layout: HorizontalPagedCollectionViewLayout(itemSizing: .usingAvailableWidth(margin: 60)))
        await verify(viewController: vc, testDarkMode: false)
    }
}

private class ViewController: UIViewController {
    
    enum Section: Hashable, Sendable {
        case main
    }
    
    enum Item: Hashable, Sendable {
        case cell(PageCell.Configuration)
    }
    
    var diffDataSource: CollectionViewDiffableDataSource<Section, Item>!
    private let layout: HorizontalPagedCollectionViewLayout
    var collectionView: UICollectionView!
    
    let mockData = [Photo](
        repeating: Photo.emptyPhoto(),
        count: 10
    )
    
    init(layout: HorizontalPagedCollectionViewLayout) {
        self.layout = layout
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        // Configure the SUT
        let horizontalLayout = layout
        horizontalLayout.minimumLineSpacing = ModuleConstants.Spacing
        horizontalLayout.sectionInset = [.left: ModuleConstants.Spacing, .right: ModuleConstants.Spacing]

        view = UIView()
        view.backgroundColor = .lightGray
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: horizontalLayout)
        collectionView.backgroundColor = .black
        view.addAutolayoutSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 300),
        ])
        let cellRegistration = PageCell.View.defaultCellRegistration()
        diffDataSource = .init(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .cell(let configuration):
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: configuration)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData { [weak self] in
            guard let self else { return }
            var snapshot = self.diffDataSource.snapshot()
            snapshot.appendSections([.main])
            self.mockData.forEach { photo in
                let configuration = PageCell.Configuration(photo: photo)
                snapshot.appendItems([.cell(configuration)])
            }
            await self.diffDataSource.apply(snapshot)
        } completion: { _ in
            
        }
    }
}

private enum ModuleConstants {
    static let Spacing: CGFloat = 16
    static let MedSpacing: CGFloat = 30
}

private enum PageCell {
    struct Configuration: UIContentConfiguration, Hashable, Sendable {
        
        let id = UUID().uuidString
        let photo: Photo
        
        nonisolated(unsafe) var state: UICellConfigurationState?
        
        func makeContentView() -> UIView & UIContentView {
            View(configuration: self)
        }
        
        func updated(for state: UIConfigurationState) -> PageCell.Configuration {
            var mutableCopy = self
            if let cellState = state as? UICellConfigurationState {
                mutableCopy.state =  cellState
            }
            return mutableCopy
        }
    }
    
    class View: UIView, UIContentView {
        
        let imageView = UIImageView()
        let colorView: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.purple.withAlphaComponent(0.85)
            return view
        }()
        
        var configuration: UIContentConfiguration
        
        init(configuration: Configuration) {
            self.configuration = configuration
            super.init(frame: .zero)
            
            imageView.contentMode = .scaleAspectFill
            addAutolayoutSubview(imageView)
            imageView.pinToSuperview()
            imageView.addAutolayoutSubview(colorView)
            colorView.pinToSuperview()
            roundCorners(radius: 22)
            
            configureFor(configuration: configuration)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configureFor(configuration: Configuration) {
            imageView.setPhoto(configuration.photo)
        }
    }
}

class PlanSelectorViewController: UIViewController {
    
    enum Constants {
        static let Spacing: CGFloat = 10
        static let ElementWidth: CGFloat = 300
    }
    
    private let titleView = TitleView()
    private let collectionView = CollectionView()
    private let buttonContainerView = ButtonContainerView()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .black
        
        view.addAutolayoutSubview(titleView)
        view.addAutolayoutSubview(collectionView)
        view.addAutolayoutSubview(buttonContainerView)
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            titleView.topAnchor.constraint(equalTo: guide.topAnchor, constant: Constants.Spacing),
            titleView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
            collectionView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: Constants.Spacing),
            collectionView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            buttonContainerView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            buttonContainerView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
            buttonContainerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData { [weak self] in
            guard let self else { return }
            var snapshot = self.collectionView.diffDataSouce.snapshot()
            snapshot.appendSections([.main])
            for _ in 0...6 {
                snapshot.appendItems([.cell(UUID.init())])
            }
            await self.collectionView.diffDataSouce.apply(snapshot)
        } completion: { _ in
            
        }

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    enum Cell {
        struct Configuration: UIContentConfiguration, Hashable {
            
            let id = UUID().uuidString
            
            var state: UICellConfigurationState?
            
            func makeContentView() -> UIView & UIContentView {
                View(configuration: self)
            }
            
            func updated(for state: UIConfigurationState) -> PlanSelectorViewController.Cell.Configuration {
                var mutableCopy = self
                if let cellState = state as? UICellConfigurationState {
                    mutableCopy.state =  cellState
                }
                return mutableCopy
            }
        }
        
        class View: UIView, UIContentView {
            var configuration: UIContentConfiguration
            
            init(configuration: Configuration) {
                self.configuration = configuration
                super.init(frame: .zero)
                
                backgroundColor = .white
                layer.cornerRadius = 10
                
                configureFor(configuration: configuration)
            }
            
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            func configureFor(configuration: Configuration) { }
        }
    }

    class CollectionView: UICollectionView, UICollectionViewDelegateFlowLayout {

        enum Section: Hashable {
            case main
        }
        
        enum Item: Hashable {
            case cell(UUID)
        }
        
        var diffDataSouce: CollectionViewDiffableDataSource<Section, Item>!
        
        init() {
            let flowLayout = HorizontalPagedCollectionViewLayout(
                itemSizing: .hardcoded(width: PlanSelectorViewController.Constants.ElementWidth),
                itemAlignment: .centered
            )
            flowLayout.minimumLineSpacing = 16
            super.init(frame: .zero, collectionViewLayout: flowLayout)
            delegate = self
            createDataSource()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func createDataSource() {
            let cellRegistration = Cell.View.defaultCellRegistration()
            
            diffDataSouce = .init(collectionView: self, cellProvider: { collectionView, indexPath, itemIdentifier in
                switch itemIdentifier {
                case .cell:
                    return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: Cell.Configuration())
                }
            })
        }
    }
    
    class ButtonContainerView: UIView {
        
        private static func createButton() -> UIButton {
            let button = UIButton()
            button.backgroundColor = .systemGreen
            button.layer.cornerRadius = 12
            button.titleLabel!.textAlignment = .center
            button.titleLabel!.lineBreakMode = .byWordWrapping
            button.titleLabel!.numberOfLines = 2//if you want unlimited number of lines put 0
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: PlanSelectorViewController.Constants.ElementWidth),
                button.heightAnchor.constraint(equalToConstant: 64)
            ])
            return button
        }
        
        let firstButton: UIButton = ButtonContainerView.createButton()
        let secondButton: UIButton = ButtonContainerView.createButton()

        override init(frame: CGRect) {
            super.init(frame: .zero)
            let stackView = UIStackView(arrangedSubviews: [firstButton, secondButton])
            stackView.alignment = .center
            stackView.distribution = .fill
            stackView.axis = .vertical
            stackView.spacing = PlanSelectorViewController.Constants.Spacing
            stackView.layoutMargins = .init(uniform: PlanSelectorViewController.Constants.Spacing)
            stackView.isLayoutMarginsRelativeArrangement = true
            addAutolayoutSubview(stackView)
            stackView.pinToSuperview()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

    }
    
    class TitleView: UIView {
        
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.attributedText = TextStyler.styler.attributedString("Pick a Plan", color: .white, forStyle: .title2)
            return label
        }()
        
        private let subtitleLabel: UILabel = {
            let label = UILabel()
            label.attributedText = TextStyler.styler.attributedString("cancel anytime", color: .white, forStyle: .body)
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: .zero)
            let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            stackView.alignment = .center
            stackView.axis = .vertical
            addAutolayoutSubview(stackView)
            stackView.pinToSuperview()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

#endif
