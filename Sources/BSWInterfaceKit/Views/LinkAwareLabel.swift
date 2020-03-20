//
//  Created by Pierluigi Cifani on 19/03/2020.
//

#if canImport(UIKit)

import UIKit

/// `UILabel` subclass that when touched, iterates
/// through the attachments in it's `attributedString`, and
/// if it's a URL, executes the `didTapOnURL` handler
open class LinkAwareLabel: UILabel {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public typealias URLHandler = (URL) -> ()
    public var didTapOnURL: URLHandler?
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let urls = LinkAwareLabel.extractURLsFrom(touches: touches, inLabel: self)
        urls.forEach {
            self.handleTapOnLink($0)
        }
        super.touchesBegan(touches, with: event)
    }
    
    /// This method is public so you can use it from any other `UILabel` subclass. Make sure to override `touchesBegan`
    /// and set it's `isUserInteractionEnabled` to `true`. You can also use this from a `UIButton` subclass like this:
    /*
     ````
     class SomeFancyButton: UIButton {
         
         override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
             guard let label = titleLabel else {
                 super.touchesBegan(touches, with: event)
                 return
             }
             let urls = LinkAwareLabel.extractURLsFrom(touches: touches, inLabel: label)
             urls.forEach {
                 self.handleTapOnLink($0)
             }
             if urls.isEmpty {
                 super.touchesBegan(touches, with: event)
             }
         }
         
         private func handleTapOnLink(_ url: URL) {
            // do your thang
        }
     }
     ````
     */
    public static func extractURLsFrom(touches: Set<UITouch>, inLabel label: UILabel) -> [URL] {
        guard
            let firstTouch = touches.first,
            let attString = label.attributedText
            else {
                return []
        }
        var tappedURLs = [URL]()
        attString.enumerateAttribute(.attachment, in: NSRange(location: 0, length: attString.length), options: .init()) { (url, range, _) in
            guard let url = url as? URL else { return }
            if firstTouch.didTapAttributedTextInLabel(label: label, inRange: range) {
                tappedURLs.append(url)
            }
        }
        return tappedURLs
    }
    
    private func handleTapOnLink(_ url: URL) {
        if let handler = didTapOnURL {
            handler(url)
        } else {
            window?.rootViewController?.presentSafariVC(withURL: url)
        }
    }
}

private extension UITouch {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: (locationOfTouchInLabel.x - textContainerOffset.x),
                                                     y: 0 );
        // Adjust for multiple lines of text
        let lineModifier = Int(ceil(locationOfTouchInLabel.y / label.font.lineHeight)) - 1
        let rightMostFirstLinePoint = CGPoint(x: labelSize.width, y: 0)
        let charsPerLine = layoutManager.characterIndex(for: rightMostFirstLinePoint, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)

        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        let adjustedRange = indexOfCharacter + (lineModifier * charsPerLine)
        var newTargetRange = targetRange
        if lineModifier > 0 {
            newTargetRange.location = targetRange.location+(lineModifier*Int(ceil(locationOfTouchInLabel.y)))
        }
        return NSLocationInRange(adjustedRange, newTargetRange)
    }
}

#endif
