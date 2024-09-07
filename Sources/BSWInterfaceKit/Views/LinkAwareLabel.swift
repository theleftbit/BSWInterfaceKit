//
//  Created by Pierluigi Cifani on 19/03/2020.
//

#if canImport(UIKit.UILabel)

import UIKit

@available(iOS 17, *)
#Preview {
    let l = LinkAwareLabel()
    l.didTapOnURL = {
        print($0)
    }
    let link = "https://www.theleftbit.com"
    let string = String(format: "Hello %@", arguments: [link])
    l.attributedText = TextStyler.styler
        .attributedString(string)
        .addingLink(onSubstring: link, linkURL: URL(string: "link")!, linkColor: .systemBlue)
    return l
}

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
    
    /**
     
     This method is public so you can use it from any other `UILabel` subclass. Make sure to override `touchesBegan` and set it's `isUserInteractionEnabled` to `true`. You can also use this from a `UIButton` subclass like this:
     
     ```
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
     ```
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
        guard UIApplication.shared.canOpenURL(url) else { return }
        if let handler = didTapOnURL {
            handler(url)
        } else {
            let vc = next() as UIViewController?
            vc?.presentSafariVC(withURL: url)
        }
    }
}

private extension UITouch {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        guard let attributedString = label.attributedText, let _ = attributedString.attribute(.font, at: 0, longestEffectiveRange: nil, in: NSRange(location: 0, length: attributedString.length)) else {
            print("No attributed string nor font found. Please provide both to enable link detection")
            return false
        }
        /// Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: attributedString)

        /// Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        /// Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = {
            /// If we don't set the height as VERY LARGE, it won't detect links on the last line.
            /// More info, here https://stackoverflow.com/a/35010994/1152289
            CGSize(width: labelSize.width, height: CGFloat.greatestFiniteMagnitude)
        }()
        
        /// Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let alignmentOffset: CGFloat = {
            /// https://gist.github.com/hamdan/e8c98db7bcdcf4cdaa2d41be248823ec#gistcomment-2896404
            switch label.textAlignment {
            case .left, .natural, .justified:
                return 0.0
            case .center:
                return 0.5
            case .right:
                return 1.0
            @unknown default:
                fatalError()
            }
        }()
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * alignmentOffset - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * alignmentOffset - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}

#endif
