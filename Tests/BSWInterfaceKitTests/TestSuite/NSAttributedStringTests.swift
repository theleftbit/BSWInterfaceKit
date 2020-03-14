#if canImport(UIKit)

import XCTest
import BSWInterfaceKit
import SnapshotTesting
import BSWSnapshotTest

class NSAttributedStringTests: XCTestCase {
    func testLinks() {
        let attributedString = NSMutableAttributedString(string: "Welcome to the jungle")
        attributedString.addLink(
            onSubstring: "jungle",
            linkURL: URL(string: "https://www.youtube.com/watch?v=o1tj2zJ2Wvg")!
        )
        assertSnapshot(matching: attributedString, as: .dump)
    }
    
    func testBolding() {
        let attributedString = TextStyler.styler.attributedString("Welcome to the jungle")
        let boldingJungle = attributedString.bolding(substring: "jungle")
        assertSnapshot(matching: boldingJungle, as: .dump)
    }

    func testLineHeightMultiplier() {
        let attributedString = TextStyler.styler.attributedString("Welcome to the jungle\nwe've got fun and games").settingLineHeightMultiplier(1.2)
        assertSnapshot(matching: attributedString, as: .dump)
    }
}

#endif
