//
//  EmailComposer.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/31/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import Foundation
import MessageUI

class EmailComposer: NSObject, MFMailComposeViewControllerDelegate {
    
    // Did this in order to mitigate needing to import MessageUI in my View Controller
    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["support@spekrapp.com"])
        mailComposerVC.setSubject("Feedback")
        mailComposerVC.setMessageBody("Hello! I have some feedback for you.", isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}
