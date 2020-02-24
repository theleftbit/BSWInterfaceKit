
#if canImport(UIKit)

import UIKit
import BSWFoundation

//MARK: SelectableTableViewDataSourceDelegate

public protocol SelectableTableViewDataSourceDelegate: class {
    func shouldSelectItem(atIndexPath: IndexPath) -> Bool
    func tableFooterView() -> (IntrinsicSizeCalculable & UIView)?
}

public extension SelectableTableViewDataSourceDelegate {
    func shouldSelectItem(atIndexPath: IndexPath) -> Bool { true }
    func tableFooterView() -> (IntrinsicSizeCalculable & UIView)? { nil }
}

//MARK: SelectableTableViewDataSource

public class SelectableTableViewDataSource<Cell: UITableViewCell & ViewModelReusable>: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    public var dataStore: SelectableArray<Cell.VM>
    weak public var tableView: UITableView!
    weak public var delegate: SelectableTableViewDataSourceDelegate?
    
    /**
    Use this datasource if you want a simple way to create a UI
    that resembles a tableView with selection

    - Parameter tableView: the `UITableView` where the content will be layed out.
    - Parameter dataStore: the `SelectableArray` that represents the data.
    - Parameter shouldForceTableViewHeight: This parameter will force the tableView's height to it's contentSize. Set this to true if you need some UIView with an intrinsic height given it's content. Please put this inside a scrollView or it won't scroll!.
     */

    public init(tableView: UITableView, dataStore: SelectableArray<Cell.VM>, shouldForceTableViewHeight: Bool = false) {
        self.dataStore = dataStore
        self.tableView = tableView
        
        super.init()
        tableView.registerReusableCell(Cell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
        if shouldForceTableViewHeight {
            heightConstraintForTableView = tableView.heightAnchor.constraint(equalToConstant: 0)
            obs = tableView.observe(\.contentSize) { [weak self] (tv, change) in
                guard let `self` = self else {
                    return
                }
                self.heightConstraintForTableView.constant = tv.contentSize.height
                self.heightConstraintForTableView.isActive = (tv.contentSize.height > 0)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var selectedIndex: Int? {
        get {
            dataStore.selectedIndex
        } set {
            guard let index = newValue else {
                return
            }
            dataStore.select(atIndex: index)
            self.tableView(tableView, didSelectRowAt: .init(row: index, section: 0))
        }
    }
    
    public var selectedElement: Cell.VM? {
        dataStore.selectedElement
    }
    
    public var elements: [Cell.VM] {
        dataStore.options
    }
    
    public func addElement(_ item: Cell.VM) {
        dataStore.appendOption(item, andSelectIt: true)
        tableView.reloadData()
    }

    //MARK: Private
    
    private var obs: NSKeyValueObservation!
    private var heightConstraintForTableView: NSLayoutConstraint!
    
    //MARK: UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStore.options.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: Cell = tableView.dequeueReusableCell(indexPath: indexPath)
        cell.configureFor(viewModel: dataStore.options[indexPath.row])
        if let selectedIndex = dataStore.selectedIndex, selectedIndex == indexPath.row {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let delegate = self.delegate else {
            return true
        }
        return delegate.shouldSelectItem(atIndexPath: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let view = self.delegate?.tableFooterView() {
            return view.heightConstrainedTo(width: tableView.frame.width)
        } else {
            return 1
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let view = self.delegate?.tableFooterView() {
            return view
        } else {
            return UIView()
        }
    }
    
    //MARK: UITableViewDelegate
        
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let allOtherSelected = tableView.indexPathsForSelectedRows?.filter({$0 != indexPath}) ?? []
        allOtherSelected.forEach {
            tableView.deselectRow(at: $0, animated: true)
        }
        dataStore.select(atIndex: indexPath.row)
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        dataStore.removeSelection()
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
}

#endif
