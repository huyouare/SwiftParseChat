//
//  ProfileViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/20/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet var userImageView: PFImageView!
    @IBOutlet var nameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentUser = PFUser.currentUser() {
            self.loadUser()
        } else {
            Utilities.loginUser(self)
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func loadUser() {
        var user = PFUser.currentUser()
        
        userImageView.file = user[PF_USER_PICTURE] as PFFile
        userImageView.loadInBackground { (image: UIImage!, error: NSError!) -> Void in
            if error != nil {
                println(error)
            }
        }
        
        nameField.text = user[PF_USER_FULLNAME] as String
    }
    
}
