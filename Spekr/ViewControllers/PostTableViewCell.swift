//
//  PostTableViewCell.swift
//  Spekr
//
//  Created by Arjun Kodur on 1/2/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit
import Parse

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var userDisplayImage: UIImageView!
    
    @IBOutlet weak var timeStamp: UILabel!
    
    @IBOutlet weak var postTextLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        
        if likeButton.selected == false {
            
            likeButton.selected = true
            
        }else {
            
            likeButton.selected = false
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    

}
