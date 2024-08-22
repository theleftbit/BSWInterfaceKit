//
//  Created by Pierluigi Cifani on 21/03/2017.
//
#if canImport(UIKit)

import BSWInterfaceKit
import XCTest

class UIViewTests: BSWSnapshotTest {

    var hostView: UIView!
    var childView: UIView!

    override func setUp() async throws {
        try await super.setUp()

        hostView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        hostView.backgroundColor = .white

        childView = UIView(frame: .zero)
        childView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        childView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        childView.backgroundColor = .red

        hostView.addAutolayoutSubview(childView)
        childView.centerInSuperview()
    }
    
    override func tearDown() async throws {
        try await super.tearDown()
        hostView.removeAllConstraints()
        childView.removeAllConstraints()
    }

    func testFillSuperview() {
        childView.fillSuperview(withMargin: 5)
        verify(view: hostView)
    }

    func testFillSuperviewLayoutMargins() {
        hostView.layoutMargins = .init(uniform: 10)
        childView.pinToSuperviewLayoutMargins()
        verify(view: hostView)
        hostView.layoutMargins = .zero
    }

    func testCenterInSuperview() {
        verify(view: hostView)
    }

    func testRoundedCorners() {
        childView.roundCorners()
        verify(view: hostView)
    }
}

#endif
