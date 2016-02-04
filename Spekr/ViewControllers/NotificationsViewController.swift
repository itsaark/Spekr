//
//  NotificationsViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 12/24/15.
//  Copyright © 2015 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse

class NotificationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        //Setting View controller's navigation item properties
        self.tabBarController?.navigationItem.title = "Notifications"
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        //Setting badge value to Nil
        (tabBarController!.tabBar.items![2]).badgeValue = nil
        

    }
    

}
