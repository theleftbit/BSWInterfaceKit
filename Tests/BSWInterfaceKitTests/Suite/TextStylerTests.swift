//
//  Created by Pierluigi Cifani on 11/04/2017.
//
#if canImport(Testing)

import BSWInterfaceKit
import Testing
import UIKit

class TextStylerTests: BSWSnapshotTest {

    var sut: TextStyler
    
    override init() {
        sut = TextStyler(fontDescriptor: .init(name: "ChalkboardSE-Light", size: 0))
        super.init()
    }

    @Test
    func title() {
        performTestFor(style: .title1)
    }

    @Test
    func headline() {
        performTestFor(style: .headline)
    }
    
    @Test
    func subheadline() {
        performTestFor(style: .subheadline)
    }

    @Test
    func body() {
        performTestFor(style: .body)
    }

    @Test
    func footnote() {
        performTestFor(style: .footnote)
    }

    @Test
    func boldedString() {
        sut = TextStyler()
        let string = sut.attributedString("Juventus", color: .black, forStyle: .body).bolded
        verify(attributedString: string)
    }

    private func performTestFor(style: UIFont.TextStyle, file: StaticString = #filePath, testName: String = #function) {
        let string = sut.attributedString("HelloWorld", color: .blue, forStyle: style)
        verify(attributedString: string, file: file, testName: testName)
    }
}

#endif
