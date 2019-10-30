//
//  Created by Pierluigi Cifani on 11/04/2017.
//
#if canImport(UIKit)

import BSWInterfaceKit
import XCTest
import SnapshotTesting

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
        let string = sut.attributedString("Juventus", color: .black, forStyle: .body).bolded
        let currentSimulatorScale = Int(UIScreen.main.scale)
        assertSnapshot(matching: string, as: .image, named: "\(currentSimulatorScale)x")
    }

    private func performTestFor(style: UIFont.TextStyle, file: StaticString = #file, testName: String = #function) {
        let string = sut.attributedString("HelloWorld", color: .blue, forStyle: style)
        let currentSimulatorScale = Int(UIScreen.main.scale)
        assertSnapshot(matching: string, as: .image, named: "\(currentSimulatorScale)x", file: file, testName: testName)
    }
}

extension Snapshotting where Value == NSAttributedString, Format == UIImage {
    public static let image: Snapshotting = Snapshotting<UIView, UIImage>.image.pullback { string in
        let label = UILabel()
        label.attributedText = string
        label.numberOfLines = 0
        label.backgroundColor = .white
        label.frame.size = label.systemLayoutSizeFitting(
            CGSize(width: 300, height: 0),
            withHorizontalFittingPriority: .defaultHigh,
            verticalFittingPriority: .defaultLow
        )
        return label
    }
}

#endif
