//
//  Created by Pierluigi Cifani on 18/02/2019.
//  Copyright © 2019 TheLeftBit. All rights reserved.
//

#if canImport(UIKit)
#if canImport(MessageUI)

import UIKit
import MessageUI

final public class MessageComposerBehavior: NSObject, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    public static let composer = MessageComposerBehavior()
        
    public func mailViewController(email: String, contents: MailContents? = nil) -> UIViewController? {
        guard MFMailComposeViewController.canSendMail() else {
            return nil
        }
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients([email])
        if let contents = contents {
            mailVC.setMessageBody(contents.body, isHTML: contents.isHTML)
        }
        return mailVC
    }

    public func smsViewController(phoneNumber: String) -> UIViewController? {
        guard MFMessageComposeViewController.canSendText() else {
            return nil
        }
        let smsVC = MFMessageComposeViewController()
        smsVC.messageComposeDelegate = self
        smsVC.recipients = [phoneNumber]
        return smsVC
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {

        controller.dismiss(animated: true, completion: nil)
    }
}

public extension MessageComposerBehavior {
    struct MailContents {
        public let body: String
        public let isHTML: Bool
        
        public init(body: String, isHTML: Bool) {
            self.body = body
            self.isHTML = isHTML
        }
    }
}

#endif
#endif
