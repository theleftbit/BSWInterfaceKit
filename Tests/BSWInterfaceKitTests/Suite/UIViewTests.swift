//
//  Created by Pierluigi Cifani on 21/03/2017.
//

import BSWInterfaceKit
import Testing
import UIKit

class UIViewTests: BSWSnapshotTest {

    var hostView: UIView!
    var childView: UIView!

    override init() {

        hostView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        hostView.backgroundColor = .white

        childView = UIView(frame: .zero)
        let widthConstraint = childView.widthAnchor.constraint(equalToConstant: 50)
        let heightConstraint = childView.heightAnchor.constraint(equalToConstant: 50)
        [widthConstraint, heightConstraint].forEach {
            $0.priority = .init(rawValue: 999)
            $0.isActive = true
        }
        childView.backgroundColor = .red

        hostView.addAutolayoutSubview(childView)
        childView.centerInSuperview()
        super.init()
    }
    
    @Test
    func fillSuperview() {
        childView.fillSuperview(withMargin: 5)
        verify(view: hostView)
    }

    @Test
    func fillSuperviewLayoutMargins() {
        hostView.layoutMargins = .init(uniform: 10)
        childView.pinToSuperviewLayoutMargins()
        verify(view: hostView)
        hostView.layoutMargins = .zero
    }

    @Test
    func centerInSuperview() {
        verify(view: hostView)
    }

    @Test
    func roundedCorners() {
        childView.roundCorners()
        verify(view: hostView)
    }
}
