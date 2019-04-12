//
//  ColumnFlowLayoutTests.swift
//  BSWInterfaceKitDemoTests
//
//  Created by Pierluigi Cifani on 12/11/2018.
//

import BSWInterfaceKit
import XCTest

@available(iOS 11, *)
class ColumnFlowLayoutTests: BSWSnapshotTest {
    
    func testLayout() {
        let vc = ViewController()
        waitABitAndVerify(viewController: vc)
    }

    func testLayoutWithHeader() {
        let vc = ViewController()
        vc.showsHeader = true
        waitABitAndVerify(viewController: vc)
    }

    func testLayoutWithFooter() {
        let vc = ViewController()
        vc.howManyCellsToShow = 1
        vc.showsFooter = true
        waitABitAndVerify(viewController: vc)
    }
}

//
//  Created by Pierluigi Cifani on 20/09/2018.
//  Copyright © 2018 The Left Bit. All rights reserved.
//

import UIKit

@available(iOS 11, *)
private class ViewController: UIViewController {

    var showsFooter: Bool {
        set {
            columnLayout.showsFooter = newValue
        } get {
            return columnLayout.showsFooter
        }
    }
    
    var showsHeader: Bool {
        set {
            columnLayout.showsHeader = newValue
        } get {
            return columnLayout.showsHeader
        }
    }
    
    var howManyCellsToShow: Int?
    
    private var columnLayout: ColumnFlowLayout {
        return collectionView.collectionViewLayout as! ColumnFlowLayout
    }
    
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: ColumnFlowLayout()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let safeView = UIView()
        safeView.backgroundColor = .red
        view.addSubview(safeView)
        safeView.pinToSuperviewSafeLayoutEdges()
        
        view.backgroundColor = UIColor.lightGray
        view.addSubview(collectionView)
        
        columnLayout.cellFactory = { [unowned self] in
            return self.factoryCellForItem(atIndexPath: $0)
        }

        columnLayout.headerFactory = { [unowned self] in
            return self.factoryHeaderForItem(atIndexPath: $0)
        }

        columnLayout.footerFactory = { [unowned self] in
            return self.factoryFooterForItem(atIndexPath: $0)
        }

        collectionView.backgroundColor = .clear
        collectionView.alwaysBounceVertical = true
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.pinToSuperview()
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: "PostCollectionViewCell")
        collectionView.register(Header.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
        collectionView.register(Footer.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer")
        collectionView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func factoryCellForItem(atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let cell = PostCollectionViewCell()
        guard let vm = mockData[safe: indexPath.item] else {
            return cell
        }
        cell.configureFor(viewModel: vm)
        return cell
    }

    private func factoryHeaderForItem(atIndexPath indexPath: IndexPath) -> UICollectionReusableView? {
        guard showsHeader else {
            return nil
        }

        return Header()
    }

    private func factoryFooterForItem(atIndexPath indexPath: IndexPath) -> UICollectionReusableView? {
        guard showsFooter else {
            return nil
        }
        
        return Footer()
    }
}


@available(iOS 11, *)
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let howManyCellsToShow = self.howManyCellsToShow {
            return howManyCellsToShow
        } else {
            return mockData.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostCollectionViewCell", for: indexPath) as! PostCollectionViewCell
        cell.configureFor(viewModel: self.mockData[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if showsHeader && kind == UICollectionView.elementKindSectionHeader {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath)
        } else if showsFooter && kind == UICollectionView.elementKindSectionFooter {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "Footer", for: indexPath)
        }
        return UICollectionReusableView()
    }
}


@available(iOS 11, *)
extension ViewController {
    var mockData: [PostCollectionViewCell.VM] {
        return [
            PostCollectionViewCell.VM(
                photo: Photo(url: nil),
                title: "Pork tail",
                description: "Bacon ipsum dolor amet ground round ham shoulder burgdoggen. Swine ribeye brisket pork belly bresaola strip steak ground round ham turducken capicola corned beef filet mignon jowl spare ribs",
                authorName: "Code Crafters",
                authorAvatar: Photo(url: nil)
            ),
            PostCollectionViewCell.VM(
                photo: Photo(url: nil),
                title: "Meatball",
                description: "Tenderloin frankfurter ham kielbasa short loin tri-tip kevin tongue beef ribs boudin.",
                authorName: "Code Crafters",
                authorAvatar: Photo(url: nil)
            ),
            PostCollectionViewCell.VM(
                photo: Photo(url: nil),
                title: "T-bone",
                description: "Spare ribs porchetta landjaeger pork filet mignon swine leberkas tri-tip venison pork loin alcatra turducken brisket kielba.",
                authorName: "Code Crafters",
                authorAvatar: Photo(url: nil)
            ),
            PostCollectionViewCell.VM(
                photo: Photo(url: nil),
                title: "Capicola ground round rump shank",
                description: "Biltong shankle venison swine. Doner short loin venison, alcatra buffalo beef burgdoggen. Swine beef ribs turducken, rump pig beef filet mignon landjaeger.",
                authorName: "Code Crafters",
                authorAvatar: Photo(url: nil)
            ),
            PostCollectionViewCell.VM(
                photo: Photo(url: nil),
                title: "Drumstick",
                description: "Pancetta bresaola leberkas, buffalo meatball alcatra swine chicken ham hock chuck. Ground round t-bone buffalo, strip steak meatball chuck tenderloin burgdoggen ball tip jowl fatback tongue tail.",
                authorName: "Code Crafters",
                authorAvatar: Photo(url: nil)
            )
        ]
    }
}
//
//  Created by Pierluigi Cifani on 20/09/2018.
//  Copyright © 2018 The Left Bit. All rights reserved.
//

import UIKit

private class PostCollectionViewCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 5
        stackView.layoutMargins = UIEdgeInsets(uniform: 10)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private let authorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 5
        return stackView
    }()
    
    private let titleLabel = UILabel.unlimitedLinesLabel()
    private let descriptionLabel = UILabel.unlimitedLinesLabel()
    private let authorAvatar = UIImageView()
    private let authorName = UILabel.unlimitedLinesLabel()
    
    struct VM {
        let photo: Photo
        let title: String
        let description: String
        let authorName: String
        let authorAvatar: Photo
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.white
        contentView.roundCorners(radius: 5)
        
        authorAvatar.contentMode = .scaleAspectFill
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        authorStackView.addArrangedSubview(authorAvatar)
        authorStackView.addArrangedSubview(authorName)
        
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(descriptionLabel)
        textStackView.addArrangedSubview(authorStackView)
        
        contentView.addAutolayoutSubview(imageView)
        contentView.addAutolayoutSubview(textStackView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: textStackView.topAnchor),
            textStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.5),
            authorAvatar.widthAnchor.constraint(equalToConstant: 30),
            authorAvatar.heightAnchor.constraint(equalTo: authorAvatar.widthAnchor)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func configureFor(viewModel: VM) {
        imageView.setPhoto(viewModel.photo)
        titleLabel.attributedText = TextStyler.styler.attributedString(viewModel.title, forStyle: .subheadline).bolded
        descriptionLabel.attributedText = TextStyler.styler.attributedString(viewModel.description, color: .gray, forStyle: .footnote)
        authorName.attributedText = TextStyler.styler.attributedString(viewModel.authorName, color: .gray, forStyle: .footnote)
        authorAvatar.setPhoto(viewModel.authorAvatar)
    }
}

private class Header: UICollectionReusableView {
    
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textAlignment = .center
        addAutolayoutSubview(label)
        layoutMargins = UIEdgeInsets(uniform: 20)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            ])
        label.attributedText = TextStyler.styler.attributedString("This is a Header", color: UIColor.black, forStyle: .headline)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class Footer: UICollectionReusableView {
    
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.textAlignment = .center
        addAutolayoutSubview(label)
        layoutMargins = UIEdgeInsets(uniform: 20)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            label.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            ])
        label.attributedText = TextStyler.styler.attributedString("This is a Footer", color: UIColor.black, forStyle: .headline)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
