
#if canImport(UIKit)

import UIKit
import BSWFoundation

//MARK: SelectableTableViewDataSource

/**
 Use this dataSource if you want a simple way to create a UI
 that resembles a tableView with selection
*/
public class SelectableTableViewDataSource<Cell: UITableViewCell & ViewModelReusable>: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    public struct Configuration {
        let shouldSelectItemAtIndexPath: (IndexPath) -> Bool
        let didSelectItemAtIndexPath: (IndexPath) -> ()
        let shouldDeselectItemAtIndexPath: (IndexPath) -> Bool
        let didDeselectItemAtIndexPath: (IndexPath) -> ()
        let sectionHeader: () -> (UIView?)
        let sectionFooter: () -> (UIView?)

        public init(
            shouldSelectItemAtIndexPath: @escaping (IndexPath) -> Bool = { _ in return true },
            didSelectItemAtIndexPath: @escaping (IndexPath) -> () = { _ in },
            shouldDeselectItemAtIndexPath: @escaping (IndexPath) -> Bool = { _ in return true },
            didDeselectItemAtIndexPath: @escaping (IndexPath) -> () = { _ in },
            sectionHeader: @escaping () -> (UIView?) = { nil },
            sectionFooter: @escaping () -> (UIView?) = { nil }) {
            
            self.shouldSelectItemAtIndexPath = shouldSelectItemAtIndexPath
            self.didSelectItemAtIndexPath = didSelectItemAtIndexPath
            self.shouldDeselectItemAtIndexPath = shouldDeselectItemAtIndexPath
            self.didDeselectItemAtIndexPath = didDeselectItemAtIndexPath
            self.sectionHeader = sectionHeader
            self.sectionFooter = sectionFooter
        }
    }
    
    public var dataStore: SelectableArray<Cell.VM>
    weak public var tableView: UITableView!
    private let configuration: Configuration
    
    /**
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
    
    public func updateElementAt(_ index: Int, with newItem: Cell.VM) {
        dataStore.updateOption(atIndex: index, option: newItem)
        tableView.reloadData()
    }

    //MARK: UITableViewDataSource

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataStore.options.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: Cell = tableView.dequeueReusableCell(indexPath: indexPath)
        cell.configureFor(viewModel: dataStore.options[indexPath.item])
        if let selectedIndex = dataStore.selectedIndex, selectedIndex == indexPath.item {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let _ = configuration.sectionHeader() {
            return UITableView.automaticDimension
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if let _ = configuration.sectionFooter() {
            return UITableView.automaticDimension
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return configuration.sectionHeader()
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = configuration.sectionFooter()
        if let footer = footer, tableView.separatorStyle == .singleLine {
            let separatorName = "SelectableTableViewDataSource.Separator"
            if let sep = footer.layer.sublayers?.first(where: { $0.name == separatorName }) {
                sep.removeFromSuperlayer()
            }
            // create layer with separator, setting color
            let sep = CALayer()
            sep.name = separatorName
            sep.backgroundColor = tableView.separatorColor?.cgColor
            sep.frame = {
                // recreate insets from existing ones in the table view
                let insets = tableView.separatorInset
                let width = tableView.bounds.width - insets.left - insets.right
                return CGRect(x: insets.left, y: -0.5, width: width, height: 0.5)
            }()
            footer.layer.addSublayer(sep)
        }
        return footer
    }
    
    //MARK: UITableViewDelegate
        
    public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if configuration.shouldSelectItemAtIndexPath(indexPath) {
            return indexPath
        } else {
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if configuration.shouldDeselectItemAtIndexPath(indexPath) {
            return indexPath
        } else {
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataStore.select(atIndex: indexPath.item)
        configuration.didSelectItemAtIndexPath(indexPath)

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
        configuration.didDeselectItemAtIndexPath(indexPath)

        tableView.performBatchUpdates({
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }, completion: { _ in
            tableView.reloadData()
        })
    }
}

#endif
