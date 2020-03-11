//
//  Created by Pierluigi Cifani.
//  Copyright © 2020 TheLeftBit SL. All rights reserved.
//

#if canImport(UIKit)

import UIKit
import BSWFoundation

public class CheckboxButton: UIView, ViewModelConfigurable {
    
    public struct VM {
        let attributedText: NSAttributedString
        let isSelected: Bool
        let tintColor: UIColor?
        
        public init(attributedText: NSAttributedString, isSelected: Bool = false, tintColor: UIColor? = nil) {
            self.attributedText = attributedText
            self.isSelected = isSelected
            self.tintColor = tintColor
        }
    }
    
    private let tableView = FixedHeightTableView()
    private var dataSource: SelectableTableViewDataSource<Cell>!
    
    public init() {
        super.init(frame: .zero)
        tableView.estimatedRowHeight = 44
        addAutolayoutSubview(tableView)
        tableView.pinToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureFor(viewModel: VM) {
        dataSource = SelectableTableViewDataSource<Cell>(
            tableView: tableView,
            dataStore: SelectableArray(options: [viewModel])
        )
    }
    
    private class Cell: UITableViewCell, ViewModelReusable {
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            textLabel?.numberOfLines = 0
            selectedBackgroundView = {
                let v = UIView()
                v.backgroundColor = .white
                return v
            }()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func configureFor(viewModel: VM) {
            tintColor = viewModel.tintColor
            isSelected = viewModel.isSelected
            textLabel?.attributedText = viewModel.attributedText
        }
    }
}

#endif
