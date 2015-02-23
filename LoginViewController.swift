//
//  LoginViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/22/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class LoginViewController: UITableViewController {

    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.emailField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func loginButtonPressed(sender: UIButton) {
        let email = emailField.text.lowercaseString
        let password = passwordField.text
        
        if countElements(email) == 0 {
            ProgressHUD.showError("Email field is empty.")
            return
        } else {
            ProgressHUD.showError("Password field is empty.")
        }
        
        ProgressHUD.show("Signing in...", interaction: true)
        PFUser.logInWithUsernameInBackground(email, password: password) { (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                PushNotication.parsePushUserAssign()
                ProgressHUD.showSuccess("Welcome back, \(user[PF_USER_FULLNAME])!")
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                if let info = error.userInfo {
                    ProgressHUD.showError(info["error"] as String)
                }
            }
        }
        
    }
}
