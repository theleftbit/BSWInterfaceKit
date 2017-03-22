//
//  ButtonConfigurationSnapshotTests.swift
//  BSWInterfaceKit
//
//  Created by Jordi Serra i Font on 22/3/17.
//
//

import XCTest
import Cartography
@testable import BSWInterfaceKit

class ContainerViewController: UIViewController {
    let sutView: UIView
    
    init(withView sutView: UIView) {
        self.sutView = sutView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sutView)
        sutView.centerInSuperview()
    }
}

class ButtonConfigurationSnapshotTests: BSWSnapshotTest {
    
    func testSnapshotButtonConfiguration() {
        
        recordMode = false
        
        //Given
        let config = ButtonConfiguration(title: "Eat Me", actionHandler: {})
        let button = UIButton(buttonConfiguration: config)
        
        //When
        let containerVC = ContainerViewController(withView: button)
        
        //Then
        waitABitAndVerify(viewController: containerVC)
    }
    
    func testSnapshotButtonConfigurationWithStyler() {
        
        recordMode = false
        
        //Given
        let config = ButtonConfiguration(
            title: TextStyler.styler.attributedString("Eat Me", color: UIColor.magenta, forStyle: .subheadline),
            backgroundColor: .yellow,
            contentInset: UIEdgeInsetsMake(10, 10, 10, 10),
            actionHandler: {}
        )
        let button = UIButton(buttonConfiguration: config)
        
        //When
        let containerVC = ContainerViewController(withView: button)
        
        //Then
        waitABitAndVerify(viewController: containerVC)
    }
    
}
