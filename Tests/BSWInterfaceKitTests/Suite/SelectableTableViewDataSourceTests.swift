#if canImport(UIKit)

import BSWFoundation
import BSWInterfaceKit
import XCTest

class SelectableTableViewDataSourceTests: BSWSnapshotTest {
    
    func testLayout() async throws {
        let vc = SelectableTableViewController()
        var vm = SelectableArray(options: [
            Cell.VM(text: "Title1"),
            Cell.VM(text: "Title2"),
            Cell.VM(text: "Title3")
        ])
        vm.select(atIndex: 0)
        vc.configureFor(viewModel: vm)
        await waitABitAndVerify(viewController: vc, testDarkMode: false)
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
