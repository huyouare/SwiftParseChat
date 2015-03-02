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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
    }
}
