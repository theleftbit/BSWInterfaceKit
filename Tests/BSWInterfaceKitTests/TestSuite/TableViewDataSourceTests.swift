#if canImport(UIKit)

import BSWFoundation
import BSWInterfaceKit
import XCTest

class TableViewDataSourceTests: BSWSnapshotTest {
    
    func testLayout() {
        let vc = TableViewController()
        let vm = [
            Cell.VM(text: "Title1"),
            Cell.VM(text: "Title2"),
            Cell.VM(text: "Title3")
        ]
        verify(viewController: vc, vm: vm)
    }
}

private class TableViewController: UIViewController, ViewModelConfigurable {
    let tableView = UITableView()
    var dataSource: TableViewDataSource<Cell>!
    
    override func loadView() {
        view = tableView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configureFor(viewModel: [Cell.VM]) {
        dataSource = TableViewDataSource<Cell>(
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
