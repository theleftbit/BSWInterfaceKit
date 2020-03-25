//
//  ScrollableTabsViewControllerTests.swift
//  Created by Pierluigi Cifani on 14/08/2018.
//
#if canImport(UIKit)

import UIKit
import BSWInterfaceKit

class ScrollableTabsViewControllerTests: BSWSnapshotTest {
    
    func testLayout() {
        let vc = ScrollableTabsViewController(viewControllers: [YellowViewController(), PurpleViewController(), RedViewController()])
        waitABitAndVerify(viewController: vc, testDarkMode: false)
    }
}

class PurpleViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Purple"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
    }
}

class YellowViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Yellow"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
        let label = UILabel()
        label.text = "Hello"
        view.addAutolayoutSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

class RedViewController: UIViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
        title = "Red"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
}

#endif
