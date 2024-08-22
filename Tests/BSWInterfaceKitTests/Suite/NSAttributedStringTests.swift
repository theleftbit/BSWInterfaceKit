#if canImport(UIKit)

import XCTest
import BSWInterfaceKit
import SnapshotTesting

class NSAttributedStringTests: XCTestCase {
    func testLinks() {
        let attributedString = NSAttributedString(string: "Welcome to the jungle")
            .addingLink(onSubstring: "jungle", linkURL: URL(string: "https://www.youtube.com/watch?v=o1tj2zJ2Wvg")!, linkColor: .systemBlue)
        assertSnapshot(of: attributedString, as: .dump)
    }
    
    func testBolding() {
        let attributedString = TextStyler.styler.attributedString("Welcome to the jungle")
        let boldingJungle = attributedString.bolding(substring: "jungle")
        assertSnapshot(of: boldingJungle, as: .dump)
    }

    func testApplyAttributes() {
        let attributedString = TextStyler.styler.attributedString("Welcome to the jungle")
        let boldingJungle = attributedString.applyAttributes([.backgroundColor: UIColor.systemRed, .foregroundColor: UIColor.white])
        assertSnapshot(of: boldingJungle, as: .dump)
    }

    func testApplyAttributes_multiple() {
        let attributedString = TextStyler.styler.attributedString("Que me muerda, que me aruñes, que me marque")
        let boldingJungle = attributedString.applyAttributes([.backgroundColor: UIColor.systemRed, .foregroundColor: UIColor.white], searchText: "me")
        assertSnapshot(of: boldingJungle, as: .dump)
    }

    func testLineHeightMultiplier() {
        let attributedString = TextStyler.styler.attributedString("Welcome to the jungle\nwe've got fun and games").settingLineHeightMultiplier(1.2)
        assertSnapshot(of: attributedString, as: .dump)
    }
}

#endif
