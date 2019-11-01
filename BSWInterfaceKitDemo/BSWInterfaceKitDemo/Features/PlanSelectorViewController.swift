//
//  Created by Pierluigi Cifani on 31/10/2019.
//  Copyright © 2019 Typeform SL. All rights reserved.
//

import UIKit
import BSWInterfaceKit

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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    class Cell: UICollectionViewCell, ViewModelReusable {
    
        struct VM {
            
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.backgroundColor = .white
            contentView.layer.cornerRadius = 10
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configureFor(viewModel: VM) {
            
        }
    }

    class CollectionView: UICollectionView, UICollectionViewDelegateFlowLayout {

        var collectionViewDataSource: CollectionViewDataSource<Cell>!
        
        init() {
            let flowLayout = HorizontalPagedCollectionViewLayout(
                itemSizing: .hardcoded(width: PlanSelectorViewController.Constants.ElementWidth),
                itemAlignment: .centered
            )
            flowLayout.minimumLineSpacing = 16
            super.init(frame: .zero, collectionViewLayout: flowLayout)
            delegate = self
            collectionViewDataSource = .init(data: [.init(), .init(), .init(), .init(), .init(), .init()], collectionView: self)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
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
