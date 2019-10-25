#if canImport(UIKit)

import XCTest
import BSWInterfaceKit

class ButtonTests: BSWSnapshotTest {

    var button: UIButton!
    let sampleImage = ButtonTests.drawCircle(size: .init(width: 35, height: 35))
    
    func testRadioButton() {
        let button = ButtonTests.buttonForRadioTests()
        verify(view: button)
    }

    func testEnabledRadioButton() {
        let button = ButtonTests.buttonForRadioTests()
        button.isSelected = true
        verify(view: button)
    }

    func testImageButton() {
        let buttonConfig = ButtonConfiguration.init(buttonTitle: .image(self.sampleImage), actionHandler: {})
        let button = UIButton(buttonConfiguration: buttonConfig)
        button.frame = CGRect(origin: .zero, size: button.intrinsicContentSize)
        verify(view: button)
    }

    func testImageButtonWithCornerRadius() {
        let buttonConfig = ButtonConfiguration.init(title: "Hello World", titleColor: .white, backgroundColor: .systemBlue, contentInset: .init(uniform: 5), cornerRadius: 5, actionHandler: {})
        let button = UIButton(buttonConfiguration: buttonConfig)
        button.frame = CGRect(origin: .zero, size: button.intrinsicContentSize)
        verify(view: button)
    }

    func testImageTitleButton() {
        let title = NSAttributedString(string: "Click Me")
        let button = UIButton(buttonConfiguration: ButtonConfiguration(buttonTitle: ButtonTitle.textAndImage(title, sampleImage), actionHandler: {}))
        button.frame = CGRect(origin: .zero, size: button.intrinsicContentSize)
        verify(view: button)
    }
    
    /// Since this tested inside a SPM, the Responder Chain is not available and `sendActions(for:)` won't work
    func _testTapButton() {
        let exp = expectation(description: "Expecting touches in button")
        
        var isActionHandled: Bool = false
        
        let button = UIButton(buttonConfiguration: ButtonConfiguration(buttonTitle: .image(sampleImage), actionHandler: {
            isActionHandled = true
            exp.fulfill()
        }))
        button.frame = CGRect(origin: .zero, size: button.intrinsicContentSize)
        
        button.sendActions(for: .touchUpInside)
        
        let _ = XCTWaiter().wait(for: [exp], timeout: 1)
        
        XCTAssert(isActionHandled)
    }

    // MARK: Private

    private static func buttonForRadioTests() -> UIButton {
        let button = CheckboxButton()
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Push Me", for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: button.intrinsicContentSize.width, height: button.intrinsicContentSize.height)
        return button
    }
    

    /// This is a function that generates a sample UIImage since we can't
    /// use Xcode Assets because we're SPM doesn't support them
    private static func drawCircle(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.green.cgColor)
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
    }
}
#endif
