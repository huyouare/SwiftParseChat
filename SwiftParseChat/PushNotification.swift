//
//  PushNotification.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/22/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import Foundation

class PushNotication {
    
    class func parsePushUserAssign() {
        var installation = PFInstallation.currentInstallation()
        installation[PF_INSTALLATION_USER] = PFUser.currentUser()
        installation.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError!) -> Void in
            if error != nil {
                println("parsePushUserAssign save error.")
            }
        }
    }
    
    class func parsePushUserResign() {
        var installation = PFInstallation.currentInstallation()
        installation.removeObjectForKey(PF_INSTALLATION_USER)
        installation.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError!) -> Void in
            if error != nil {
                println("parsePushUserResign save error")
            }
        }
    }
    
    class func sendPushNotification(roomId: String, text: String) {
        var query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query.whereKey(PF_MESSAGES_ROOMID, equalTo: roomId)
        query.whereKey(PF_MESSAGES_USER, equalTo: PFUser.currentUser())
        query.includeKey(PF_MESSAGES_USER)
        query.limit = 1000
        
        var installationQuery = PFInstallation.query()
        installationQuery.whereKey(PF_INSTALLATION_USER, matchesKey: PF_MESSAGES_USER, inQuery: query)
        
        var push = PFPush()
        push.setQuery(installationQuery)
        push.setMessage(text)
        push.sendPushInBackgroundWithBlock { (succeeded: Bool, error: NSError!) -> Void in
            if error != nil {
                println("sendPushNotification error")
            }
        }
    }
    
}