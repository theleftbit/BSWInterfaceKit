#if canImport(UIKit)

import BSWFoundation
import BSWInterfaceKit
import XCTest

class SelectableTableViewDataSourceTests: BSWSnapshotTest {
    
    func testLayout() throws {
        let vc = SelectableTableViewController()
        var vm = SelectableArray(options: [
            Cell.VM(text: "Title1"),
            Cell.VM(text: "Title2"),
            Cell.VM(text: "Title3")
        ])
        vm.select(atIndex: 0)
        
        verify(viewController: vc, vm: vm)
    }
}

private class SelectableTableViewController: UIViewController, ViewModelConfigurable {
    let tableView = UITableView()
    var dataSource: SelectableTableViewDataSource<Cell>!
    
    override func loadView() {
        view = tableView
    }
    
    func configureFor(viewModel: SelectableArray<Cell.VM>) {
        dataSource = SelectableTableViewDataSource<Cell>(
            tableView: tableView,
            dataStore: viewModel
        )
    }
}

private class Cell: UITableViewCell, ViewModelReusable {
    struct VM {
        let text: String
    }
    
    func configureFor(viewModel: VM) {
        textLabel?.text = viewModel.text
    }
}

#endif
