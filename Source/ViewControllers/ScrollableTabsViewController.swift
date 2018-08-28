//
//  Created by Pierluigi Cifani on 23/11/2017.
//  Copyright © 2018 TheLeftBit SL. All rights reserved.
//

import UIKit

@objc(BSWScrollableTabsViewController)
public class ScrollableTabsViewController: UIViewController {
    
    public enum Appearance {
        public static let headerHeight: CGFloat = 50
        public static var indicatorHeight: CGFloat = 2
        public static var tabsColor: UIColor = .black
        public static var indicatorColor: UIColor = .black
        public static var backgroundColor: UIColor = .white
    }
    
    public var viewControllers: [UIViewController] {
        didSet {
            fatalError("Not yet supported")
        }
    }
    
    fileprivate var previousContentOffset = CGPoint(x: 0, y: 0)
    fileprivate var headerDataSource: HeaderDataSource!
    fileprivate var contentDataSource: ContentDataSource!
    fileprivate let headerCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.backgroundColor = Appearance.backgroundColor
        return collectionView
    }()
    fileprivate let contentCollectionView: UICollectionView = {
        let contentCollectionLayout = UICollectionViewFlowLayout()
        contentCollectionLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: contentCollectionLayout)
        collectionView.backgroundColor = .white
        collectionView.isPagingEnabled = true
        collectionView.allowsSelection = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        return collectionView
    }()
    
    public init(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Appearance.backgroundColor
        headerDataSource = HeaderDataSource(collectionView: headerCollectionView, viewControllers: self.viewControllers, delegate: self)
        contentDataSource = ContentDataSource(collectionView: contentCollectionView, viewControllers: self.viewControllers, delegate: self, parentViewController: self)
        view.addAutolayoutSubview(headerCollectionView)
        view.addAutolayoutSubview(contentCollectionView)
        
        NSLayoutConstraint.activate([
            headerCollectionView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            headerCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerCollectionView.heightAnchor.constraint(equalToConstant: Appearance.headerHeight),
            contentCollectionView.topAnchor.constraint(equalTo: headerCollectionView.bottomAnchor),
            contentCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        
        self.reloadData()
        selectTab(at: 0)
    }
    
    func reloadData() {
        headerCollectionView.reloadData()
        contentCollectionView.reloadData()
    }
    
    public override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in
            self.headerCollectionView.collectionViewLayout.invalidateLayout()
            self.headerCollectionView.reloadData()
            self.headerCollectionView.collectionViewLayout.invalidateLayout()
            self.contentCollectionView.reloadData()
        }, completion: nil)
    }
}

extension ScrollableTabsViewController: ScrollableTabHeaderSelectionDelegate, ScrollableTabContentSelectionDelegate {
    
    func selectTab(at index: Int, animated: Bool = true) {
        guard self.viewControllers.count > index && index >= 0 else { return }
        selectTabTitle(at: index, animated: animated)
        selectTabContent(at: index, animated: animated)
    }
    
    func selectTabTitle(at index: Int, animated: Bool = true) {
        guard self.viewControllers.count > index && index >= 0 else { return }
        headerCollectionView.selectItem(
            at: IndexPath(row: index, section: 0),
            animated: animated,
            scrollPosition: .centeredHorizontally
        )
    }
    
    func selectTabContent(at index: Int, animated: Bool = true) {
        guard self.viewControllers.count > index && index >= 0 else { return }
        let tabsContentOffset = CGPoint(
            x: view.bounds.size.width * CGFloat(index),
            y: contentCollectionView.contentOffset.y
        )
        contentCollectionView.setContentOffset(tabsContentOffset, animated: animated)
    }
    
    func titleSelected(at index: Int) {
        selectTabContent(at: index, animated: true)
    }
    
    func pagingContent(to index: Int, withVelocity: CGFloat) {
        selectTabTitle(at: index)
    }
    
    func scrollingContent(with offset: CGPoint, isDragging: Bool) {
        guard isDragging == true else { return }
        var newTitlesOffset = CGPoint(x: 0, y: offset.y)
        if offset.x - previousContentOffset.x > 0 {
            newTitlesOffset.x = headerCollectionView.contentOffset.x + 1
        } else {
            newTitlesOffset.x = headerCollectionView.contentOffset.x - 1
        }
        headerCollectionView.setContentOffset(newTitlesOffset, animated: false)
        previousContentOffset = offset
    }
}

//MARK: Protocols

private protocol ScrollableTabContentSelectionDelegate: class {
    func pagingContent(to index: Int, withVelocity: CGFloat)
    func scrollingContent(with offset: CGPoint, isDragging: Bool)
}

private protocol ScrollableTabHeaderSelectionDelegate: class {
    func titleSelected(at index: Int)
}

//MARK: DataSources

extension ScrollableTabsViewController {
    
    fileprivate class ContentDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
        
        let reuseID = "ScrollableTabsContentViewCellReuseID"
        
        private unowned var collectionView: UICollectionView
        private var viewControllers: [UIViewController]
        private weak var delegate: ScrollableTabContentSelectionDelegate?
        private var isDragging: Bool = false
        private unowned var parentViewController: UIViewController
        
        init(collectionView: UICollectionView, viewControllers: [UIViewController], delegate: ScrollableTabContentSelectionDelegate, parentViewController: UIViewController) {
            self.collectionView = collectionView
            self.viewControllers = viewControllers
            self.delegate = delegate
            self.parentViewController = parentViewController
            super.init()
            
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(ScrollableTabsViewController.ContentViewCell.self, forCellWithReuseIdentifier: reuseID)
        }
        
        // MARK: - UICollectionViewDataSource
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return viewControllers.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: reuseID,
                for: indexPath) as? ScrollableTabsViewController.ContentViewCell
                else {
                    fatalError()
            }
            
            cell.removeChildViewController()
            cell.addChildViewController(
                viewControllers[indexPath.item],
                from: parentViewController
            )
            
            return cell
        }
        
        // MARK: - UICollectionViewDelegateFlowLayout
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            sizeForItemAt indexPath: IndexPath) -> CGSize {
            return collectionView.bounds.size
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
        
        // MARK: - UIScrollView Events
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            isDragging = true
        }
        
        func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            let offset = targetContentOffset.pointee
            let pageWidth = scrollView.bounds.size.width
            let scrollingToPage = Int(((offset.x) + pageWidth/2) / pageWidth)
            delegate?.pagingContent(to: scrollingToPage, withVelocity: abs(velocity.x))
            isDragging = false
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            delegate?.scrollingContent(with: scrollView.contentOffset, isDragging: isDragging)
        }
    }
    
    fileprivate class HeaderDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
        
        private let reuseID = "HeaderCellReuseID"
        private var viewControllers: [UIViewController]
        
        private unowned var collectionView: UICollectionView
        private unowned var delegate: ScrollableTabHeaderSelectionDelegate
        
        internal init(collectionView: UICollectionView, viewControllers: [UIViewController], delegate: ScrollableTabHeaderSelectionDelegate) {
            self.collectionView = collectionView
            self.viewControllers = viewControllers
            self.delegate = delegate
            super.init()
            
            guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { fatalError() }
            flowLayout.estimatedItemSize = CGSize(width: 100, height: Appearance.headerHeight)
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(ScrollableTabsViewController.HeaderViewCell.self, forCellWithReuseIdentifier: reuseID)
        }
        
        // MARK: - UICollectionViewDataSource
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return viewControllers.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as? ScrollableTabsViewController.HeaderViewCell else {
                fatalError()
            }
            cell.configure(for: viewControllers[indexPath.item].title!)
            return cell
        }
        
        // MARK: - UICollectionViewDelegate
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            delegate.titleSelected(at: indexPath.row)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
        // MARK: - UICollectionViewDelegateFlowLayout
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
        
        func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 0
        }
    }
}

//MARK: Cells

extension ScrollableTabsViewController {
    
    @objc(BSWScrollableTabsViewControllerHeaderCell)
    fileprivate class HeaderViewCell: UICollectionViewCell {
        
        private let bottomBar = UIView()
        private let titleLabel = UILabel()
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }
        
        required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        open func setup() {
            bottomBar.alpha = 0
            bottomBar.backgroundColor = Appearance.indicatorColor

            contentView.addAutolayoutSubview(bottomBar)
            contentView.addAutolayoutSubview(titleLabel)
            titleLabel.pinToSuperview(withEdges: UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10))
            NSLayoutConstraint.activate([
                contentView.heightAnchor.constraint(equalToConstant: Appearance.headerHeight),
                bottomBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                bottomBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                bottomBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                bottomBar.heightAnchor.constraint(equalToConstant: Appearance.indicatorHeight),
                ])
        }
        
        override open var isSelected: Bool {
            didSet {
                UIView.animate(
                    withDuration: 0.5,
                    delay: 0,
                    options: .curveEaseInOut,
                    animations: { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.bottomBar.alpha = strongSelf.isSelected ? 1 : 0
                    }, completion: nil)
            }
        }
        
        func configure(for title: String) {
            titleLabel.attributedText = TextStyler.styler.attributedString(title, color: Appearance.tabsColor, forStyle: .title3)
        }
    }
    
    @objc(BSWScrollableTabsViewControllerContentCell)
    fileprivate class ContentViewCell: UICollectionViewCell {
        
        var childViewController: UIViewController?
        
        func addChildViewController(_ contentViewController: UIViewController, from parentViewController: UIViewController) {
            self.childViewController = contentViewController
            parentViewController.addChild(contentViewController)
            contentViewController.didMove(toParent: parentViewController)
            contentView.addSubview(contentViewController.view)
            setupConstraints()
        }
        
        func removeChildViewController() {
            guard let contentViewController = childViewController else { return }
            contentViewController.view.removeFromSuperview()
            contentViewController.willMove(toParent: nil)
            contentViewController.removeFromParent()
        }
        
        func setupConstraints() {
            guard let view = childViewController?.view else { return }
            view.pinToSuperview()
        }
    }
}
