//
//  NittyGrittyViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/31/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit
import MessageUI

class NittyGrittyViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    //Initializing mail composer
    let emailComposer = EmailComposer()
    
    //Dismiss mail VC after getting a result.
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
    }

    @IBAction func getInTouchButtonTapped(){
        
        //Calling Email composer class to send feedback via e-mail
        if emailComposer.canSendMail() {
            let configuredMailComposeViewController = emailComposer.configuredMailComposeViewController("Help")
            configuredMailComposeViewController.mailComposeDelegate = self
            self.presentViewController(configuredMailComposeViewController, animated: true, completion: nil)
            
            
        }else{
            
            SweetAlert().showAlert("Could Not Send Email", subTitle: "Your device couldn't send the e-mail. Please check the device configuration and try again later", style: AlertStyle.None)
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.title = "Nitty Gritty"
    }
    


}
