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
    
    var chatrooms: [AnyObject]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.currentUser() != nil {
            self.loadChatRooms()
        } else {
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
                self.chatrooms.extend(objects)
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
                    // Save PFObject
                }
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        cell.textLabel?.text = "Hello"
        return cell
    }
}
