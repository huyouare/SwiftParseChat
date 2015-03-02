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

class PrivateViewController: UITableViewController {
    
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

}
