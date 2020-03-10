
#if canImport(UIKit)

import UIKit
import BSWFoundation

//MARK: SelectableTableViewDataSource

public class SelectableTableViewDataSource<Cell: UITableViewCell & ViewModelReusable>: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    public struct Configuration {
        let shouldSelectItemAtIndexPath: (IndexPath) -> Bool

        public init(shouldSelectItemAtIndexPath:  @escaping (IndexPath) -> Bool = { _ in return true}) {
            self.shouldSelectItemAtIndexPath = shouldSelectItemAtIndexPath
        }
    }
    
    public var dataStore: SelectableArray<Cell.VM>
    weak public var tableView: UITableView!
    private let configuration: Configuration
    
    /**
    Use this datasource if you want a simple way to create a UI
    that resembles a tableView with selection

    - Parameter tableView: the `UITableView` where the content will be layed out.
    - Parameter dataStore: the `SelectableArray` that represents the data.
    - Parameter configuration: Customizations for this class.
     */

    public init(tableView: UITableView, dataStore: SelectableArray<Cell.VM>, configuration: Configuration = .init()) {
        self.dataStore = dataStore
        self.tableView = tableView
        self.configuration = configuration
        
        super.init()
        tableView.registerReusableCell(Cell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: false)
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStore.options.count
    }
    
    //MARK: UITableViewDataSource
    
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
        return configuration.shouldSelectItemAtIndexPath(indexPath)
    }
        
    //MARK: UITableViewDelegate
        
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataStore.select(atIndex: indexPath.row)

        let allOtherSelected = tableView.indexPathsForSelectedRows?.filter({$0 != indexPath}) ?? []

        tableView.performBatchUpdates({
            allOtherSelected.forEach {
                tableView.deselectRow(at: $0, animated: true)
            }
        }, completion: { _ in
            tableView.reloadData()
        })
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        dataStore.removeSelection()
        tableView.performBatchUpdates({
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }, completion: { _ in
            tableView.reloadData()
        })
    }
}

#endif
