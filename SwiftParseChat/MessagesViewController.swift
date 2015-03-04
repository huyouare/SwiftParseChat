//
//  MessagesViewController.swift
//  
//
//  Created by Jesse Hu on 3/3/15.
//
//

import UIKit

class MessagesViewController: UITableViewController {
    
    var messages = [PFObject]()
    // UITableViewController already declares refreshControl
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "cleanup", name: NOTIFICATION_USER_LOGGED_OUT, object: nil)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: "loadMessages", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        //viewEmpty.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if PFUser.currentUser() != nil {
            self.loadMessages()
        } else {
            Utilities.loginUser(self)
        }
    }
    
    // MARK: - Backend methods
    
    func loadMessages() {
        let query = PFQuery(className: PF_MESSAGES_CLASS_NAME)
        query.whereKey(PF_MESSAGES_USER, equalTo: PFUser.currentUser())
        query.includeKey(PF_MESSAGES_LASTUSER)
        query.orderByDescending(PF_MESSAGES_UPDATEDACTION)
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                messages.removeAll(keepCapacity: false)
                messages += objects as [PFObject]!
                self.tableView.reloadData()
                self.updateEmptyView()
                self.updateTabCounter()
            } else {
                ProgressHUD.showError("Network error")
                refreshControl?.endRefreshing()
            }
        }
    }
    
    class func refreshMessagesView() {
        
    }
    
}
