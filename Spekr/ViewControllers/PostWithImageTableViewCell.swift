//
//  PostWithImageTableViewCell.swift
//  Spekr
//
//  Created by Arjun Kodur on 1/3/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit

class PostWithImageTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var userDisplayImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    
    @IBOutlet weak var postTextView: UITextView!
    
    
    @IBOutlet weak var postImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
