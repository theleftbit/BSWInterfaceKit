//
//  Created by Pierluigi Cifani on 11/04/2017.
//
#if canImport(UIKit)

import BSWInterfaceKit
import XCTest

class TextStylerTests: BSWSnapshotTest {

    var sut: TextStyler!
    override func setUp() {
        super.setUp()
        sut = TextStyler(fontDescriptor: .init(name: "ChalkboardSE-Light", size: 0))
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
        sut = TextStyler()
        let string = sut.attributedString("Juventus", color: .black, forStyle: .body).bolded
        verify(attributedString: string)
    }

    private func performTestFor(style: UIFont.TextStyle, file: StaticString = #file, testName: String = #function) {
        let string = sut.attributedString("HelloWorld", color: .blue, forStyle: style)
        verify(attributedString: string, file: file, testName: testName)
    }
}

#endif
