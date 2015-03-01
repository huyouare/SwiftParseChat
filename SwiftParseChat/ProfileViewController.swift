//
//  ProfileViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/20/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIActionSheetDelegate, UIImagePickerControllerDelegate {
    
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
        
        userImageView.layer.cornerRadius = userImageView.frame.size.width / 2;
        userImageView.layer.masksToBounds = true;
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
    
    func saveUser() {
        let fullName = nameField.text
        if countElements(fullName) > 0 {
            var user = PFUser.currentUser()
            user[PF_USER_FULLNAME] = fullName
            user[PF_USER_FULLNAME_LOWER] = fullName.lowercaseString
            user.saveInBackgroundWithBlock({ (succeeded: Bool, error: NSError!) -> Void in
                if error == nil {
                    ProgressHUD.showSuccess("Saved")
                } else {
                    ProgressHUD.showError("Network error")
                }
            })
        } else {
            ProgressHUD.showError("Name field must not be empty")
        }
    }
    
    // MARK: - User actions
    
    func cleanup() {
        userImageView.image = UIImage(named: "profile_blank")
        nameField.text = nil;
    }
    
    func logout() {
        var actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Log out")
        actionSheet.showFromTabBar(self.tabBarController?.tabBar)
        
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            PFUser.logOut()
            PushNotication.parsePushUserResign()
            Utilities.postNotification(NOTIFICATION_USER_LOGGED_OUT)
            self.cleanup()
            Utilities.loginUser(self)
        }
    }
    
    @IBAction func photoButtonPressed(sender: UIButton) {
        // Camera
    }
    
    @IBAction func saveButtonPressed(sender: UIButton) {
        self.dismissKeyboard()
        self.saveUser()
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var image = info[UIImagePickerControllerEditedImage] as UIImage
        if image.size.width > 140 {
            image = Utilities.resizeImage(image, width: 140, height: 140)
        }
        
        var pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(image, 0.6))
        pictureFile.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError!) -> Void in
            if error != nil {
                ProgressHUD.showError("Network error")
            }
        }
        
        userImageView.image = image
        
        if image.size.width > 30 {
            image = Utilities.resizeImage(image, width: 30, height: 30)
        }
        
        var thumbnailFile = PFFile(name: "thumbnail.jpg", data: UIImageJPEGRepresentation(image, 0.6))
        thumbnailFile.saveInBackgroundWithBlock { (succeeded: Bool, error: NSError!) -> Void in
            if error != nil {
                ProgressHUD.showError("Network error")
            }
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

}
