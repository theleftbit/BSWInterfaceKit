//
//  Created by Pierluigi Cifani on 11/04/2017.
//

import BSWInterfaceKit
import XCTest

class TextStylerTests: BSWSnapshotTest {

    var sut: TextStyler!
    override func setUp() {
        super.setUp()
        sut = TextStyler()
        sut.preferredFontName = "ChalkboardSE-Light"
    }

    func testTitle() {
        performTestFor(style: .title1)
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

    func testBoldedString() {
        sut.preferredFontName = nil
        let string = sut.attributedString("Juventus", color: .black, forStyle: .body).bolded()
        performTestFor(string: string)
    }

    private func performTestFor(style: UIFontTextStyle) {
        self.performTestFor(string: sut.attributedString("HelloWorld", color: .blue, forStyle: style))
    }

    private func performTestFor(string: NSAttributedString) {
        let label = UILabel()
        label.attributedText = string
        label.frame = CGRect(origin: .zero, size: label.intrinsicContentSize)
        waitABitAndVerify(view: label)
    }
}
