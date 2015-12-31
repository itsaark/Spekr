//
//  ComposeViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/28/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse

class ComposeViewController: UIViewController {
    
    
    @IBOutlet weak var charLimitLabel: UILabel!
    
    @IBOutlet weak var composeTextView: UITextView!
    
    //User tapped attachImage button
    @IBAction func attachImageButton(sender: AnyObject) {
        
        
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
        
        //setting view controller's title
        self.title = "Compose"
        
        //Setting Compose Text View as First Responder when the view appears
        self.composeTextView.becomeFirstResponder()

    }

   

}
