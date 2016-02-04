//
//  WorldFeedViewController.swift
//  Spekr
//
//  Created by Arjun Kodur on 1/26/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse

class WorldFeedViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.tabBarController?.navigationItem.title = "World Feed"
        self.tabBarController?.navigationController?.navigationBarHidden = false
        self.tabBarController?.navigationItem.setHidesBackButton(true, animated: false)
        self.tabBarController?.navigationItem.rightBarButtonItem = nil

        
    }
    
    override func viewDidAppear(animated: Bool) {
        
        
    }

}
