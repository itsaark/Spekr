//
//  NotificationTableViewCell.swift
//  Spekr
//
//  Created by Arjun Kodur on 2/11/16.
//  Copyright © 2016 Arjun Kodur. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var fromUserDisplayImage: UIImageView!
    
    @IBOutlet weak var timeStamp: UILabel!
    
    @IBOutlet weak var postTextLabel: UILabel!
    
    @IBOutlet weak var fromUserDisplayName: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
