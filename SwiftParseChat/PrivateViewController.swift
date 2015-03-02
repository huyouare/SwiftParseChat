//
//  PrivateViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/20/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import AddressBook
import MessageUI

class PrivateViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate {
    
    var users1 = [APContact]()
    var users2 = [PFUser]()
    var indexSelected: NSIndexPath!
    
    // activity: UIActivityIndicatorView
    
    let addressBook = APAddressBook()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cleanup", name: NOTIFICATION_USER_LOGGED_OUT, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            // Load address book
            self.addressBook.fieldsMask = APContactField.Default | APContactField.Emails

            self.addressBook.sortDescriptors = [NSSortDescriptor(key: "firstName", ascending: true), NSSortDescriptor(key: "lastName", ascending: true)]
            self.addressBook.loadContacts({ (contacts: [AnyObject]!, error: NSError!) -> Void in
                // TODO: Add actiivtyIndicator
                // self.activity.stopAnimating()
                self.users1.removeAll(keepCapacity: false)
                if contacts != nil {
                    for contact in contacts as [APContact]! {
                        self.users1.append(contact)
                    }
                    self.loadUsers()
                } else if error != nil {
                    ProgressHUD.showError("Error loading contacts")
                    println(error)
                }
            })
        }
        else {
            Utilities.loginUser(self)
        }
    }
    
    // MARK: - User actions
    
    func cleanup() {
        users1.removeAll(keepCapacity: false)
        users2.removeAll(keepCapacity: false)
        self.tableView.reloadData()
    }
    
    func loadUsers() {
        var emails = [String]()
        
        for user in users1 {
            if let userEmails = user.emails {
                emails += userEmails as [String]
            }
        }
        
        var user = PFUser.currentUser()
        
        var query = PFQuery(className: PF_USER_CLASS_NAME)
        query.whereKey(PF_USER_OBJECTID, notEqualTo: user.objectId)
        query.whereKey(PF_USER_EMAILCOPY, containedIn: emails)
        query.orderByAscending(PF_USER_FULLNAME)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.users2.removeAll(keepCapacity: false)
                for user in objects as [PFUser]! {
                    self.users2.append(user)
                    self.removeUser(user[PF_USER_EMAILCOPY] as String)
                }
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
            }
        }
    }
    
    func removeUser(removeEmail: String) {
        var removeUsers = [APContact]()
        
        for user in users1 {
            if let userEmails = user.emails {
                for email in userEmails as [String] {
                    if email == removeEmail {
                        removeUsers.append(user)
                        break
                    }
                }
            }
        }
        
        let filtered = self.users1.filter { !contains(removeUsers, $0) }
        self.users1 = filtered
    }
    
    // MARK: - UITableViewDataSource 
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return users2.count
        }
        if section == 1 {
            return users1.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && users2.count > 0 {
            return "Registered users"
        }
        if section == 1 && users1.count > 0 {
            return "Non-registered users"
        }
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell
        
        if indexPath.section == 0 {
            let user = users2[indexPath.row]
            cell.textLabel?.text = user[PF_USER_FULLNAME] as? String
            cell.detailTextLabel?.text = user[PF_USER_EMAILCOPY] as? String
        }
        else if indexPath.section == 1 {
            let user = users1[indexPath.row]
            let email = user.emails.first as? String
            let phone = user.phones.first as? String
            cell.textLabel?.text = "\(user.firstName) \(user.lastName)"
            cell.detailTextLabel?.text = (email != nil) ? email : phone
        }
        
        cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            let user1 = PFUser.currentUser()
            let user2 = users2[indexPath.row]
            let roomId = Messages.startPrivateChat(user1, user2: user2)
            
            self.performSegueWithIdentifier("privateChatSegue", sender: roomId)
        }
        else if indexPath.section == 1 {
            self.indexSelected = indexPath
            self.inviteUser(self.users1[indexPath.row])
        }
    }
    
    // MARK: - Prepare for segue to private chatVC
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "privateChatSegue" {
            let chatVC = segue.destinationViewController as ChatViewController
            chatVC.hidesBottomBarWhenPushed = true
            let roomId = sender as String
            chatVC.roomId = roomId
        }
    }
    
    // MARK: - Invite helper method
    
    func inviteUser(user: APContact) {
        let emailsCount = countElements(user.emails)
        let phonesCount = countElements(user.phones)
        
        if emailsCount > 0 && phonesCount > 0 {
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Email invitation", "SMS invitation")
            actionSheet.showFromTabBar(self.tabBarController?.tabBar)
        } else if emailsCount > 0 && phonesCount == 0 {
            self.sendMail(user)
        } else if emailsCount == 0 && phonesCount > 0 {
            self.sendSMS(user)
        } else {
            ProgressHUD.showError("Contact has no email or phone number")
        }
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            let user = users1[indexSelected.row]
            if buttonIndex == 1 {
                self.sendMail(user)
            } else if buttonIndex == 2 {
                self.sendSMS(user)
            }
        }
    }
    
    // MARK: - Mail sending method
    
    func sendMail(user: APContact) {
        if MFMailComposeViewController.canSendMail() {
            var mailCompose = MFMailComposeViewController()
            // TODO: Use one email rather than all emails
            mailCompose.setToRecipients(user.emails as [String]!)
            mailCompose.setSubject("")
            mailCompose.setMessageBody(MESSAGE_INVITE, isHTML: true)
            mailCompose.mailComposeDelegate = self
            self.presentViewController(mailCompose, animated: true, completion: nil)
        } else {
            ProgressHUD.showError("Email not configured")
        }
    }
    
    // MARK: - MailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        if result.value == MFMailComposeResultSent.value {
            ProgressHUD.showSuccess("Invitation email sent successfully")
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - SMS sending method
    
    func sendSMS(user: APContact) {
        if MFMessageComposeViewController.canSendText() {
            var messageCompose = MFMessageComposeViewController()
            // TODO: Use primary phone rather than all numbers
            messageCompose.recipients = user.phones as [String]!
            messageCompose.body = MESSAGE_INVITE
            messageCompose.messageComposeDelegate = self
            self.presentViewController(messageCompose, animated: true, completion: nil)
        } else {
            ProgressHUD.showError("SMS cannot be sent")
        }
    }
    
    // MARK: - MessageComposeViewControllerDelegate
    
    func messageComposeViewController(controller: MFMessageComposeViewController!, didFinishWithResult result: MessageComposeResult) {
        if result.value == MessageComposeResultSent.value {
            ProgressHUD.showSuccess("Invitation SMS sent successfully")
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
