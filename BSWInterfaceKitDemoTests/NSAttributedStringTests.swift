//
//  Created by Pierluigi Cifani on 13/05/2019.
//

import XCTest
import BSWInterfaceKit
import SnapshotTesting

class NSAttributedStringTests: XCTestCase {
    func testLinks() {
        let attributedString = NSMutableAttributedString(string: "Welcome to the jungle")
        attributedString.addLink(
            onSubstring: "jungle",
            linkURL: URL(string: "https://www.youtube.com/watch?v=o1tj2zJ2Wvg")!
        )
        assertSnapshot(matching: attributedString, as: .dump)
    }

    func testLinksColor() {
        let attributedString = NSMutableAttributedString(string: "Welcome to the jungle")
        attributedString.addLink(
            onSubstring: "jungle",
            linkURL: URL(string: "https://www.youtube.com/watch?v=o1tj2zJ2Wvg")!,
            linkColor: UIColor.red
        )
        assertSnapshot(matching: attributedString, as: .dump)
    }
}
