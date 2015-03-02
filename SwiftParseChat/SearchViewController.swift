//
//  SearchViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 3/1/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class SearchViewController: UITableViewController {
    
    var users = [PFUser]()
    
    @IBOutlet var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadUsers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    func loadUsers() {
        var user = PFUser.currentUser()
        
        var query = PFQuery(className: PF_USER_CLASS_NAME)
        query.whereKey(PF_USER_OBJECTID, notEqualTo: user.objectId)
        query.orderByAscending(PF_USER_FULLNAME)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.users.removeAll(keepCapacity: false)
                self.users += objects as [PFUser]!
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
            }
        }
    }
    
    func searchUsers(searchString: String) {
        let user = PFUser.currentUser()
        
        var query = PFQuery(className: PF_USER_CLASS_NAME)
        query.whereKey(PF_USER_OBJECTID, notEqualTo: user.objectId)
        query.whereKey(PF_USER_FULLNAME_LOWER, containsString: searchString)
        query.orderByAscending(PF_USER_FULLNAME)
        query.limit = 1000
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                self.users.removeAll(keepCapacity: false)
                self.users += objects as [PFUser]!
                self.tableView.reloadData()
            } else {
                ProgressHUD.showError("Network error")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
    }
    
}
