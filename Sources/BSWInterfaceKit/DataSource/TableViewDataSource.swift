
#if canImport(UIKit)

import UIKit
import BSWFoundation

//MARK: TableViewDataSourceDelegate

public protocol TableViewDataSourceDelegate: class {
    func deleteAt(_ row: Int)
    func canEditRow() -> Bool
    func tableFooterView() -> (IntrinsicSizeCalculable & UIView)?
}

public extension TableViewDataSourceDelegate {
    func deleteAt(_ row: Int) {}
    func canEditRow() -> Bool { false }
    func tableFooterView() -> (IntrinsicSizeCalculable & UIView)? { nil }
}

//MARK: TableViewDataSource

public class TableViewDataSource<Cell: UITableViewCell & ViewModelReusable>: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    public var dataStore: [Cell.VM]
    weak public var tableView: UITableView!
    weak public var delegate: TableViewDataSourceDelegate?
    
    /**
    Use this datasource if you want a simple way to create a tableView

    - Parameter tableView: the `UITableView` where the content will be layed out.
    - Parameter dataStore: the `Array` that represents the data.
     */

    public init(tableView: UITableView, dataStore: [Cell.VM]) {
        self.dataStore = dataStore
        self.tableView = tableView
        
        super.init()
        tableView.registerReusableCell(Cell.self)
        tableView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func addElement(_ item: Cell.VM) {
        dataStore.append(item)
        tableView.reloadData()
    }
    
    //MARK: UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStore.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: Cell = tableView.dequeueReusableCell(indexPath: indexPath)
        cell.configureFor(viewModel: dataStore[indexPath.row])
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return delegate?.canEditRow() ?? false
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard delegate?.canEditRow() ?? false else { return }
        if editingStyle == .delete {
            delegate?.deleteAt(indexPath.row)
        }
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return true
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
}

#endif
