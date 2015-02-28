//
//  GroupViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/20/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
// Parse loaded from SwiftParseChat-Bridging-Header.h

class GroupViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate {
    
    var chatrooms: [PFObject]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if PFUser.currentUser() != nil {
            self.loadChatRooms()
        }
        else {
            Utilities.loginUser(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadChatRooms() {
        var query = PFQuery(className: PF_CHATROOMS_CLASS_NAME)
        query.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]!, error: NSError!)  in
            if error == nil {
                self.chatrooms.removeAll()
                self.chatrooms.extend(objects as [PFObject]!)
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
                println(error)
            }
        }
    }
    
    @IBAction func newButtonPressed(sender: UIBarButtonItem) {
        self.actionNew()
    }
    
    func actionNew() {
        var alert = UIAlertView(title: "Please enter a name for your group", message: "", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "OK")
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.show()
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            var textField = alertView.textFieldAtIndex(0);
            if let text = textField!.text {
                if countElements(text) > 0 {
                    var object = PFObject(className: PF_CHATROOMS_CLASS_NAME)
                    object[PF_CHATROOMS_NAME] = text
                    object.saveInBackgroundWithBlock({ (success: Bool, error: NSError!) -> Void in
                        if success {
                            self.loadChatRooms()
                        } else {
                            ProgressHUD.showError("Network error")
                            println(error)
                        }
                    })
                }
            }
        }
    }
    
    // MARK: - TableView Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        var chatroom = self.chatrooms[indexPath.row]
        cell.textLabel?.text = chatroom[PF_CHATROOMS_NAME] as? String
        
        var query = PFQuery(className: PF_CHAT_CLASS_NAME)
        query.whereKey(PF_CHAT_ROOMID, equalTo: chatroom.objectId)
        query.orderByDescending(PF_CHAT_CREATEDAT)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                if let chat = objects.first as? PFObject {
                    let date = NSDate()
                    let seconds = date.timeIntervalSinceDate(chat.createdAt)
                    let elapsed = Utilities.timeElapsed(seconds);
                    cell.detailTextLabel?.text = "\(objects.count) messages \(elapsed)"
                }
            } else {
                cell.detailTextLabel?.text = "No message"
            }
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var chatroom = chatrooms[indexPath.row]
        let roomId = chatroom.objectId as String
        
        Messages.createMessageItem(PFUser(), roomId: roomId, description: chatroom[PF_CHATROOMS_NAME] as String)
        
        self.performSegueWithIdentifier("groupChatSegue", sender: roomId)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "groupChatSegue" {
            let chatVC = segue.destinationViewController as ChatViewController
            chatVC.hidesBottomBarWhenPushed = true
            let roomId = sender as String
            chatVC.roomId = roomId
        }
    }
}
