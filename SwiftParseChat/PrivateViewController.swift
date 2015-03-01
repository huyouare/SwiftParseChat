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
    
    var users1 = [[String:String]]()
    var users2 = [[String:String]]()
    
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
            let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
            ABAddressBookRequestAccessWithCompletion(addressBook, { (granted: Bool, error: CFError!) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if granted {
                        self.loadAddressBook()
                    }
                })
            })
        } else {
            Utilities.loginUser(self)
        }
    }
    
    // MARK: - User actions
    
    func cleanup() {
        users1.removeAll(keepCapacity: false)
        users2.removeAll(keepCapacity: false)
        self.tableView.reloadData()
    }
    
//    func loadAddressBook() {
//        if ABAddressBookGetAuthorizationStatus() == ABAuthorizationStatus.Authorized {
//
//            let addressBook: ABAddressBook = ABAddressBookCreateWithOptions(nil, nil).takeRetainedValue()
//            let sourceBook: ABRecordRef = ABAddressBookCopyDefaultSource(addressBook).takeRetainedValue()
//            let allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, sourceBook, ABPersonGetSortOrdering())
//            let personCount = CFArrayGetCount(allPeople.takeRetainedValue())
//            
//            users1.removeAll(keepCapacity: false)
//            
//            for i in 0..<personCount {
//                var tmp: ABMultiValueRef!
//                let person: ABRecordRef = CFArrayGetValueAtIndex(allPeople.takeRetainedValue(), i as CFIndex).memory as ABRecor
//                
//                var first = ""
//                tmp = ABRecordCopyValue(person, kABPersonFirstNameProperty)
//                if tmp != nil {
//                    first = "\(tmp)"
//                }
//                
//                var last = ""
//                tmp = ABRecordCopyValue(person, kABPersonLastNameProperty)
//                if tmp != nil {
//                    last = "\(tmp)"
//                }
//                
//                let emails = [String]()
//                
//                let multi1 = ABRecordCopyValue(person, kABPersonEmailProperty)
//                for j in 0..<ABMultiValueGetCount(multi1) {
//                    tmp = ABMultiValueCopyValueAtIndex(multi1, j)
//                    if tmp != nil {
//                        emails.append("\(tmp)")
//                    }
//                }
//                
//                let phones = [String]()
//                
//                let multi2 = ABRecordCopyValue(person, kABPersonPhoneProperty)
//                for j in 0..<ABMultiValueGetCount(multi2) {
//                    tmp = ABMultiValueCopyValueAtIndex(multi2, j)
//                    if tmp != nil {
//                        phones.append("\(tmp)")
//                    }
//                }
//                
//                let name = "\(first) \(last)"
//                users1.append(["name": name, "emails": emails, "phones": phones])
//            }
//            self.loadUsers()
//        }
//    }
//    
//    func loadUsers() {
//        let emails = [String]()
//        for user in users1 {
//            emails += user["emails"]
//        }
//        
//        var user = PFUser.currentUser()
//        
//        var query = PFQuery(className: PF_USER_CLASS_NAME)
//        query.whereKey(PF_USER_OBJECTID, notEqualTo: user.objectId)
//        query.whereKey(PF_USER_EMAILCOPY, containedIn: emails)
//        query.orderByAscending(PF_USER_FULLNAME)
//        query.limit = 1000
//        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
//            if error == nil {
//                users2.removeAll(keepCapacity: false)
//                for user in objects as [PFUser]! {
//                    
//                }
//            }
//        }
//    }
}
