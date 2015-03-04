//
//  MessagesCell.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 3/3/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class MessagesCell: UITableViewCell {
    
    @IBOutlet var userImage: PFImageView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var lastMessageLabel: UILabel!
    @IBOutlet var timeElapsedLabel: UILabel!
    @IBOutlet var counterLabel: UILabel!
    
    func bindData(message: PFObject) {
        userImage.layer.cornerRadius = userImage.frame.size.width / 2
        userImage.layer.masksToBounds = true
        
        lastUser = message[PF_MESSAGES_LASTUSER] as PFUser
        userImage.file = lastUser[PF_USER_PICTURE] as PFFile
        userImage.loadInBackground(nil)
        
        descriptionLabel.text = message[PF_MESSAGES_DESCRIPTION]
        lastMessageLabel.text = [PF_MESSAGES_LASTMESSAGE]
        
        let seconds = NSDate().timeIntervalSinceDate(message[PF_MESSAGES_UPDATEDACTION] as NSDate)
        timeElapsedLabel.text = Utilities.timeElapsed(seconds)
        
        let counter = message[PF_MESSAGES_COUNTER].intValue
        counterLabel.text = (counter == 0) ? "" : "\(counter) new"
    }
    
}
