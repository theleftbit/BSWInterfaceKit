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

    @MainActor
    func testTitle() {
        performTestFor(style: .title1)
    }

    @MainActor
    func testHeadline() {
        performTestFor(style: .headline)
    }

    @MainActor
    func testSubheadline() {
        performTestFor(style: .subheadline)
    }

    @MainActor
    func testBody() {
        performTestFor(style: .body)
    }

    @MainActor
    func testFootnote() {
        performTestFor(style: .footnote)
    }

    @MainActor
    func testBoldedString() {
        sut = TextStyler()
        let string = sut.attributedString("Juventus", color: .black, forStyle: .body).bolded
        verify(attributedString: string)
    }

    @MainActor
    private func performTestFor(style: UIFont.TextStyle, file: StaticString = #file, testName: String = #function) {
        let string = sut.attributedString("HelloWorld", color: .blue, forStyle: style)
        verify(attributedString: string, file: file, testName: testName)
    }
}

#endif
