#if canImport(UIKit)

import BSWInterfaceKit
import BSWFoundation
import XCTest

class UIColorTests: BSWSnapshotTest {
    func testInvertColors() {
        let testColor = UIColor.systemBackground
        let lightVariation = testColor.resolvedColor(with: .init(userInterfaceStyle: .light))
        let darkVariation = testColor.invertedForUserInterfaceStyle()
        XCTAssertNotEqual(lightVariation, darkVariation)
    }
}

#endif
