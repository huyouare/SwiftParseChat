//
//  RegisterViewController.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/21/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit

class RegisterViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "dismissKeyboard"))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
}
