#if canImport(UIKit)
#if canImport(Testing)

import BSWInterfaceKit
import SnapshotTesting
import Testing
import UIKit

struct NSAttributedStringTests {
    
    @Test
    func links() {
        let attributedString = NSAttributedString(string: "Welcome to the jungle")
            .addingLink(onSubstring: "jungle", linkURL: URL(string: "https://www.youtube.com/watch?v=o1tj2zJ2Wvg")!, linkColor: .systemBlue)
        assertSnapshot(of: attributedString, as: .dump)
    }
    
    @Test
    func bolding() {
        let attributedString = TextStyler.styler.attributedString("Welcome to the jungle")
        let boldingJungle = attributedString.bolding(substring: "jungle")
        assertSnapshot(of: boldingJungle, as: .dump)
    }

    @Test
    func applyAttributes() {
        let attributedString = TextStyler.styler.attributedString("Welcome to the jungle")
        let boldingJungle = attributedString.applyAttributes([.backgroundColor: UIColor.systemRed, .foregroundColor: UIColor.white])
        assertSnapshot(of: boldingJungle, as: .dump)
    }

    @Test
    func applyAttributes_multiple() {
        let attributedString = TextStyler.styler.attributedString("Que me muerda, que me aruñes, que me marque")
        let boldingJungle = attributedString.applyAttributes([.backgroundColor: UIColor.systemRed, .foregroundColor: UIColor.white], searchText: "me")
        assertSnapshot(of: boldingJungle, as: .dump)
    }

    @Test
    func lineHeightMultiplier() {
        let attributedString = TextStyler.styler.attributedString("Welcome to the jungle\nwe've got fun and games").settingLineHeightMultiplier(1.2)
        assertSnapshot(of: attributedString, as: .dump)
    }
}

#endif
#endif
