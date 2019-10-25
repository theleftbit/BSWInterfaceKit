//
//  Created by Pierluigi Cifani on 18/02/2019.
//  Copyright © 2019 TheLeftBit. All rights reserved.
//

#if canImport(UIKit)

import UIKit
import MessageUI

final public class MailComposerBehavior: NSObject, MFMailComposeViewControllerDelegate {
    public static let composer = MailComposerBehavior()
    
    public func mailViewController(email: String) -> UIViewController? {
        guard MFMailComposeViewController.canSendMail() else {
            return nil
        }
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        mailVC.setToRecipients([email])
        return mailVC
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

#endif
