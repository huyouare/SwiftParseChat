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

class PrivateViewController: UITableViewController, UITableViewDelegate, UITableViewDataSource {
    
    var users1 = [APContact]()
    var users2 = [PFUser]()
    
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
            // TODO: Maybe mask for emails
            //self.addressBook.filterBlock = {(contact: APContact!) -> Bool in
            //    return contact.emails.count > 0
            //}
            self.addressBook.loadContacts({ (contacts: [AnyObject]!, error: NSError!) -> Void in
                // self.activity.stopAnimating()
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
        
        println(emails)
        
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
        
        self.users1.filter { !contains(removeUsers, $0) }
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
        
        cell.detailTextLabel?.text = UIColor.lightGrayColor()
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            let user1 = PFUser.currentUser()
            let user2 = users2[indexPath.row]
            let roomId = Messages.startPrivateChat(user1, user2: user2)
            
            var chatView = 
        }
    }

}
