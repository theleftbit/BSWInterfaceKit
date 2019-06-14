//
//  Created by Pierluigi Cifani on 21/03/2017.
//

import BSWInterfaceKit
import XCTest

class UIViewTests: BSWSnapshotTest {

    var hostView: UIView!
    var childView: UIView!

    override func setUp() {
        super.setUp()

        hostView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        hostView.backgroundColor = .white

        childView = UIView(frame: .zero)
        childView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        childView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        childView.backgroundColor = .red

        hostView.addAutolayoutSubview(childView)
        childView.centerInSuperview()
    }

    func testFillSuperview() {
        hostView.removeAllConstraints()
        childView.removeAllConstraints()
        childView.fillSuperview(withMargin: 5)
        verify(view: hostView)
    }

    func testCenterInSuperview() {
        verify(view: hostView)
    }

    func testRoundedCorners() {
        childView.roundCorners()
        verify(view: hostView)
    }
}
