//
//  RegisterViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/21/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class RegisterViewController: UITableViewController {
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.nameField.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)

    }
    
    @IBAction func registerButtonPressed(sender: UIButton) {
//        let name = nameField.text
//        let email = emailField.text
//        let password = passwordField.text.lowercaseString
//        
////        if ([name length] == 0)		{ [ProgressHUD showError:@"Name must be set."]; return; }
////        if ([password length] == 0)	{ [ProgressHUD showError:@"Password must be set."]; return; }
////        if ([email length] == 0)	{ [ProgressHUD showError:@"Email must be set."]; return; }
//        
////        	[ProgressHUD show:@"Please wait..." Interaction:NO];
//        
//        var user = PFUser()
//        user.username = email
//        user.password = password
//        user.email = email
//        user[PF_USER_EMAILCOPY] = email
//        user[PF_USER_FULLNAME] = name
//        user[PF_USER_FULLNAME_LOWER] = name.lowercaseString
//        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError!) -> Void in
//            if error == nil {
//                // TODO: Notification methods
////                ParsePushUserAssign()
////                [ProgressHUD showSuccess:@"Succeed."];
//                self.dismissViewControllerAnimated(true, completion: nil)
//            } else {
////                [ProgressHUD showError:error.userInfo[@"error"]];
//            }
//        }
//        HUDController.sharedController.contentView = HUDContentView.SubtitleView(subtitle: "Error", image: HUDAssets.crossImage)
//        HUDController.sharedController.show()
//        HUDController.sharedController.hide(afterDelay: 0.5)
    }

}
