#if canImport(UIKit)

import UIKit
import XCTest
import BSWInterfaceKit
import BSWSnapshotTest

class IntrinsicSizeCalculableTests: XCTestCase {

    func testIntrinsicSizingWorks() {
        let sut = SomeView()
        XCTAssert(sut.heightConstrainedTo(width: 300) == SomeView.HardcodedHeight)

        let sut2 = SomeViewThatOverridesIntrinsicSize()
        XCTAssert(sut2.heightConstrainedTo(width: 300) == SomeViewThatOverridesIntrinsicSize.HardcodedHeight)
    }
}


private class SomeView: UIView, IntrinsicSizeCalculable {

    static let HardcodedHeight: CGFloat = 20

    init() {
        super.init(frame: .zero)
        heightAnchor.constraint(equalToConstant: SomeView.HardcodedHeight).isActive = true
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class SomeViewThatOverridesIntrinsicSize: UIView, IntrinsicSizeCalculable {
    
    static let HardcodedHeight: CGFloat = 45
    
    func heightConstrainedTo(width: CGFloat) -> CGFloat {
        SomeViewThatOverridesIntrinsicSize.HardcodedHeight
    }
}

#endif
