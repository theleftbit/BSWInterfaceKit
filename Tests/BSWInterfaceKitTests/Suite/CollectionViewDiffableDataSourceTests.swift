
#if canImport(UIKit)

import BSWInterfaceKit
import UIKit

class CollectionViewDiffableDataSourceTests: BSWSnapshotTest {
    
    func testLayout() async {
        let cv = MockCollectionView()
        let sut = cv.diffDataSource!
        var snapshot = sut.snapshot()
        snapshot.appendSections([.defenders, .midfields])
        snapshot.appendItems(MockCollectionView.mockDataDefenders().map({ .content($0)}), toSection: .defenders)
        await sut.apply(snapshot, animatingDifferences: false)
        verify(scrollView: cv)
    }
}

private class ViewController: UIViewController {
    
    let collectionView = MockCollectionView()
    
    override func loadView() {
        view = collectionView
    }
}

private class MockCollectionView: UICollectionView {
    
    var diffDataSource: CollectionViewDiffableDataSource<Section, Item>!

    init() {
        let columnLayout = ColumnFlowLayout()
        super.init(frame: .zero, collectionViewLayout: columnLayout)
        columnLayout.minColumnWidth = 120
        columnLayout.cellFactory = { [unowned self] indexPath in
            let cell = PolaroidCollectionViewCell()
            if let item = self.diffDataSource.snapshot().itemIdentifiers(inSection: .defenders)[safe: indexPath.item], case .content(let vm) = item {
                cell.configureFor(viewModel: vm)
            }
            if let item = self.diffDataSource.snapshot().itemIdentifiers(inSection: .midfields)[safe: indexPath.item], case .content(let vm) = item {
                cell.configureFor(viewModel: vm)
            }
            return cell
        }
        
        let cellRegistration = UICollectionView.CellRegistration<PolaroidCollectionViewCell, Item> { cell, indexPath, item in
            guard case .content(let vm) = item else { fatalError() }
            cell.configureFor(viewModel: vm)
        }
        diffDataSource = CollectionViewDiffableDataSource(collectionView: self, cellProvider: { (cv, index, item) -> UICollectionViewCell? in
            return cv.dequeueConfiguredReusableCell(using: cellRegistration, for: index, item: item)
        })
        
        diffDataSource.emptyConfiguration = .init(title: TextStyler.styler.attributedString("Empty View", color: .red), message: nil, image: nil, button: nil)
        diffDataSource.pullToRefreshProvider = .init(tintColor: .blue, fetchHandler: { snapshot in
            snapshot.appendItems(MockCollectionView.mockDataMidfields().map({ .content($0)}), toSection: .midfields)
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func mockDataDefenders() -> [PolaroidCollectionViewCell.VM] {
        let vm1 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/vUMmWxu.jpg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Gigi Buffon", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#1", forStyle: .body)
        )
        
        let vm2 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/SPwnhVF.jpg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Gianluca Zambrotta", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#19", forStyle: .body)
        )
        
        let vm3 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/27RoHaJ.jpg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Fabio Cannavaro", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#5", forStyle: .body)
        )
        
        let vm4 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/4OLw6YE.jpg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Marco Materazzi", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#23", forStyle: .body)
        )
        
        let vm5 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/oM0WAGL.jpg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Fabio Grosso", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#3", forStyle: .body)
        )
        
        return [vm1, vm2, vm3, vm4, vm5]
    }
    
    static func mockDataMidfields() -> [PolaroidCollectionViewCell.VM] {
        let vm1 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/HTo6Xmm.jpg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Gattuso", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#8", forStyle: .body)
        )
        
        let vm2 = PolaroidCollectionViewCell.VM(
            cellImage: Photo(url: URL(string: "https://i.imgur.com/ZH3wAf8.jpeg")!, size: CGSize(width: 320, height: 480)),
            cellTitle: TextStyler.styler.attributedString("Pirlo", forStyle: .title1),
            cellDetails: TextStyler.styler.attributedString("#21", forStyle: .body)
        )
        
        return [vm1, vm2]
    }
}


private enum Section { case defenders, midfields }
private enum Item: PagingCollectionViewItem, Hashable {
    case loading
    case content(PolaroidCollectionViewCell.VM)
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        default:
            return false
        }
    }
    
    static func loadingItem() -> Item {
        Item.loading
    }
}

private class ColumnFlowLayout: UICollectionViewLayout {
    
    // These are used to create a factory cell to calculate the size.
    // of the scrollable content of the collectionView. Please return
    // a configured cell for the given index path without using
    // dequeueCell like this:
    // https://i.imgur.com/LxYrTZB.png https://i.imgur.com/TCwbLeC.png
    public typealias CellFactory = (IndexPath) -> UICollectionViewCell
    public typealias HeaderFooterFactory = (IndexPath) -> UICollectionReusableView?

    open var cellFactory: CellFactory!

    open var headerFactory: HeaderFooterFactory = { _ in
        return nil
    }
    open var footerFactory: HeaderFooterFactory = { _ in
        return nil
    }

    open var minColumnWidth = CGFloat(200) {
        didSet {
            invalidateLayout()
        }
    }
    open var itemSpacing = CGFloat(10) {
        didSet {
            invalidateLayout()
        }
    }
    
    open var showsHeader: Bool = false {
        didSet {
            invalidateLayout()
        }
    }

    open var showsFooter: Bool = false {
        didSet {
            invalidateLayout()
        }
    }
    
    open var showsHeaderAndFooterWhenEmpty = false

    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var availableWidth: CGFloat {
        guard let cv = collectionView else { return 0 }
        return cv.bounds.inset(by: cv.layoutMargins).size.width
    }
    
    open override func invalidateLayout() {
        super.invalidateLayout()
        
        // Clear all cached values
        cache.removeAll()
        contentHeight = 0
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return false }
        return cv.bounds.size.width != newBounds.size.width
    }
    
    override open func prepare() {
        super.prepare()
        guard let cv = collectionView else { return }
        guard cache.isEmpty else { return }
        // Figure out how many columns we can fit
        let maxNumColumns = Int(availableWidth / minColumnWidth)
        let columnWidth = (availableWidth / CGFloat(maxNumColumns)).rounded(.down)
        let numberOfColumns = Int(availableWidth / columnWidth)
        let cellWidth = (availableWidth - CGFloat(numberOfColumns - 1)*itemSpacing)/CGFloat(numberOfColumns)
        let numberOfSections = cv.numberOfSections
        guard numberOfColumns > 0, numberOfSections > 0 else {
            /// The `availableWidth` is lower than the `minColumnWidth`, giving up
            return
        }
        // Figure out where each column starts in X
        let xOffset: [CGFloat] = {
            var offsets: [CGFloat] = []
            for currentColumn in 0 ..< numberOfColumns {
                if currentColumn == 0 {
                    offsets.append(cv.layoutMargins.left)
                } else {
                    let previousOffset = offsets[currentColumn - 1]
                    offsets.append(previousOffset + cellWidth + itemSpacing)
                }
            }
            return offsets
        }()
        let numberOfItems = cv.numberOfItems(inSection: 0)
        let shouldShowAccesoryViews: Bool = {
            if numberOfItems > 0 {
                return true
            } else {
                return showsHeaderAndFooterWhenEmpty
            }
        }()
        
        var headerOffset: CGFloat = 0
        let headerIndexPath = IndexPath(item: 0, section: 0)
        let _header: UICollectionReusableView? = {
            guard showsHeader && shouldShowAccesoryViews else {
                return nil
            }
            return self.headerFactory(headerIndexPath)
        }()
        
        if let header = _header {
            let headerWidth = cv.frame.width
            let height = ColumnFlowLayout.reusableViewHeight(view: header, availableWidth: headerWidth)
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: headerIndexPath)
            attributes.frame = CGRect(x: 0, y: 0, width: headerWidth, height: height)
            cache.append(attributes)
            headerOffset = attributes.frame.maxY
        }

        let yStartOffset = headerOffset > 0 ? headerOffset : (cv.layoutMargins.top - cv.safeAreaInsets.top)
        var yOffset = [CGFloat](repeating: yStartOffset, count: numberOfColumns)

        //Now we calculate the UICollectionViewLayoutAttributes for each cell
        var currentColumn: Int = 0
        for item in 0 ..< numberOfItems {
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let cell = self.cellFactory(indexPath)
            let cellFrame: CGRect = {
                // Automatically calculate the height of the cell using Autolayout
                let height = ColumnFlowLayout.cellHeight(cell: cell, availableWidth: cellWidth)
                let frame = CGRect(x: xOffset[currentColumn], y: yOffset[currentColumn], width: cellWidth, height: height)
                let isFirstCellInColumn = (yOffset[currentColumn] == yStartOffset)
                return frame.offsetBy(dx: 0, dy: isFirstCellInColumn ? 0 : itemSpacing)
            }()
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = cellFrame
            cache.append(attributes)
            
            // Do some book-keeping to make sure the next
            // iteration uses the updated values
            contentHeight = max(contentHeight, cellFrame.maxY)
            yOffset[currentColumn] = cellFrame.maxY
            currentColumn = currentColumn < (numberOfColumns - 1) ? (currentColumn + 1) : 0
        }
        
        let _footer: UICollectionReusableView? = {
            guard showsFooter && shouldShowAccesoryViews else {
                return nil
            }
            return self.footerFactory(headerIndexPath)
        }()
        
        if let footer = _footer {
            let footerWidth = cv.frame.width
            let height = ColumnFlowLayout.reusableViewHeight(view: footer, availableWidth: footerWidth)
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: headerIndexPath)
            attributes.frame = CGRect(x: 0, y: cache.last?.frame.maxY ?? 0, width: footerWidth, height: height)
            cache.append(attributes)
            contentHeight += height
        }

        contentHeight += cv.layoutMargins.bottom
    }
    
    override open var collectionViewContentSize: CGSize {
        return CGSize(width: availableWidth, height: contentHeight)
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect)}
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[safe: indexPath.item]
    }

    static func reusableViewHeight(view: UICollectionReusableView, availableWidth: CGFloat) -> CGFloat {
        if let intrinsicSizeCalculable = view as? IntrinsicSizeCalculable {
            return intrinsicSizeCalculable.heightConstrainedTo(width: availableWidth)
        } else {
            let estimatedSize = view.systemLayoutSizeFitting(
                CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            return estimatedSize.height
        }
    }

    static func cellHeight(cell: UICollectionViewCell, availableWidth: CGFloat) -> CGFloat {
        if let intrinsicSizeCalculable = cell as? IntrinsicSizeCalculable {
            return intrinsicSizeCalculable.heightConstrainedTo(width: availableWidth)
        } else {
            let estimatedSize = cell.contentView.systemLayoutSizeFitting(
                CGSize(width: availableWidth, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            )
            return estimatedSize.height
        }
    }
}

//MARK: Cells

@objc(BSWPolaroidCollectionViewCell)
private class PolaroidCollectionViewCell: UICollectionViewCell, ViewModelReusable {

    //MARK: ViewModel
    public struct VM: Hashable, Sendable {
        public let id: Int?
        public let cellImage: Photo
        public nonisolated(unsafe) let cellTitle: NSAttributedString
        public nonisolated(unsafe) let cellDetails: NSAttributedString

        public init(id: Int? = nil, cellImage: Photo, cellTitle: NSAttributedString, cellDetails: NSAttributedString) {
            self.id = id
            self.cellImage = cellImage
            self.cellTitle = cellTitle
            self.cellDetails = cellDetails
        }
    }

    private let detailSubview = PolaroidCollectionCellBasicInfoView()
    
    private let cellImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    private let stackView = UIStackView()

    public static let MaxImageHeightProportion = CGFloat(2)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        stackView.addArrangedSubview(cellImageView)
        stackView.addArrangedSubview(detailSubview)
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        contentView.addAutolayoutSubview(stackView)
        stackView.pinToSuperview()

        setupImageConstraint()
        setupRoundedCorners()
        addShadow(opacity: 0.1, radius: 4, offset: .zero)
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.backgroundColor = UIColor.clear
        cellImageView.cancelImageLoadFromURL()
        cellImageView.image = nil
    }

    /// This is a placeholder constraint to make sure that when doing the final
    /// layout for the wanted viewModel, the image height is not compressed
    private var imageHeightConstraint: NSLayoutConstraint!
    
    private func setupImageConstraint(multiplier: CGFloat = 1) {
        if let imageHeightConstraint = self.imageHeightConstraint {
            cellImageView.removeConstraint(imageHeightConstraint)
        }
        imageHeightConstraint = cellImageView.heightAnchor.constraint(equalTo: cellImageView.widthAnchor, multiplier: multiplier)
        NSLayoutConstraint.activate([imageHeightConstraint])
    }
    
    private func setupRoundedCorners() {
        contentView.roundCorners()
    }
    
    open func configureFor(viewModel: VM) {

        //Set the basic info
        detailSubview.setTitle(viewModel.cellTitle, subtitle: viewModel.cellDetails)

        //Set the image
        cellImageView.setPhoto(viewModel.cellImage)
        if let imageSize = viewModel.cellImage.size {
            let ratio = min(imageSize.height/imageSize.width, PolaroidCollectionViewCell.MaxImageHeightProportion)
            setupImageConstraint(multiplier: ratio)
        } else {
            setupImageConstraint()
        }
    }
}

//MARK: - Subviews

private class PolaroidCollectionCellBasicInfoView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 2
        return stackView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTitle(_ title: NSAttributedString? =  nil, subtitle: NSAttributedString? = nil) {
        titleLabel.attributedText = title
        detailLabel.attributedText = subtitle
    }
    
    private func setup() {
        backgroundColor = .white
        addAutolayoutSubview(stackView)
        stackView.pinToSuperview()
        stackView.layoutMargins = UIEdgeInsets(uniform: 8)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(detailLabel)
    }
}

#endif
