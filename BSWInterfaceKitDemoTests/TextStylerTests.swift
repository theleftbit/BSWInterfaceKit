//
//  Created by Pierluigi Cifani on 11/04/2017.
//

@testable import BSWInterfaceKit
import XCTest

class TextStylerTests: BSWSnapshotTest {

    var sut: TextStyler!
    override func setUp() {
        super.setUp()
        sut = TextStyler()
        sut.preferredFontName = "ChalkboardSE-Light"

        recordMode = true
    }

    func testTitle() {
        performTestFor(style: .title)
    }

    func testHeadline() {
        performTestFor(style: .headline)
    }

    func testSubheadline() {
        performTestFor(style: .subheadline)
    }

    func testBody() {
        performTestFor(style: .body)
    }

    func testFootnote() {
        performTestFor(style: .footnote)
    }
    private func performTestFor(style: TextStyler.Style) {
        let label = UILabel()
        label.attributedText = sut.attributedString("HelloWorld", color: .blue, forStyle: style)
        label.frame = CGRect(origin: .zero, size: label.intrinsicContentSize)
        waitABitAndVerify(view: label)
    }
}
