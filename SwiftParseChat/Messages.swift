//
//  Messages.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/21/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import Foundation

class Messages {
    
    class func startPrivateChat(user1: PFUser, user2: PFUser) -> String {
        let id1 = user1.objectId
        let id2 = user2.objectId
        
        let groupId = (id1 < id2) ? "\(id1)\(id2)" : "\(id2)\(id1)"
        
        createMessageItem(user1, groupId: groupId, description: user2[PF_USER_FULLNAME] as String)
        createMessageItem(user2, groupId: groupId, description: user1[PF_USER_FULLNAME] as String)
        
        return groupId
    }

    class func startMultipleChat(users: [PFUser]!) -> String {
        var groupId = ""
        var description = ""
        
        var userIds = [String]()
        
        for user in users {
            userIds.append(user.objectId)
        }
        
        let sorted = userIds.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        
        for userId in sorted {
            groupId = groupId + userId
        }
        
        for user in users {
            if countElements(description) > 0 {
                description = description + " & "
            }
            description = description + (user[PF_USER_FULLNAME] as String)
        }
        
        for user in users {
            Messages.createMessageItem(user, groupId: groupId, description: description)
        }
        
        return groupId
    }
    
    class func createMessageItem(user: PFUser, groupId: String, description: String) {
        var query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query.whereKey(PF_MESSAGES_USER, equalTo: user)
        query.whereKey(PF_MESSAGES_GROUPID, equalTo: groupId)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if objects.count == 0 {
                    var message = PFObject(className: PF_MESSAGES_CLASS_NAME)
                    message[PF_MESSAGES_USER] = user;
                    message[PF_MESSAGES_GROUPID] = groupId;
                    message[PF_MESSAGES_DESCRIPTION] = description;
                    message[PF_MESSAGES_LASTUSER] = PFUser.currentUser()
                    message[PF_MESSAGES_LASTMESSAGE] = "";
                    message[PF_MESSAGES_COUNTER] = 0
                    message[PF_MESSAGES_UPDATEDACTION] = NSDate()
                    message.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                        if (error != nil) {
                            println("Messages.createMessageItem save error.")
                            println(error)
                        }
                    })
                }
            } else {
                println("Messages.createMessageItem save error.")
                println(error)
            }
        }
    }
    
    class func deleteMessageItem(message: PFObject) {
        message.deleteInBackgroundWithBlock { (succeeded: Bool, error: NSError!) -> Void in
            if error != nil {
                println("UpdateMessageCounter save error.")
                println(error)
            }
        }
    }
    
    class func updateMessageCounter(groupId: String, lastMessage: String) {
        var query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query.whereKey(PF_MESSAGES_GROUPID, equalTo: groupId)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for message in objects as [PFObject]! {
                    var user = message[PF_MESSAGES_USER] as PFUser
                    if user.objectId == PFUser.currentUser().objectId {
                        message.incrementKey(PF_MESSAGES_COUNTER) // Increment by 1
                        message[PF_MESSAGES_LASTUSER] = PFUser.currentUser()
                        message[PF_MESSAGES_LASTMESSAGE] = lastMessage
                        message[PF_MESSAGES_UPDATEDACTION] = NSDate()
                        message.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                            if error != nil {
                                println("UpdateMessageCounter save error.")
                                println(error)
                            }
                        })
                    }
                }
            } else {
                println("UpdateMessageCounter save error.")
                println(error)
            }
        }
    }
    
    class func clearMessageCounter(groupId: String) {
        var query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query.whereKey(PF_MESSAGES_GROUPID, equalTo: groupId)
        query.whereKey(PF_MESSAGES_USER, equalTo: PFUser.currentUser())
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                for message in objects as [PFObject]! {
                    message[PF_MESSAGES_COUNTER] = 0
                    message.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                        if error != nil {
                            println("ClearMessageCounter save error.")
                            println(error)
                        }
                    })
                }
            } else {
                println("ClearMessageCounter save error.")
                println(error)
            }
        }
    }

}
