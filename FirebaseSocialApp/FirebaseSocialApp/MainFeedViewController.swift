//
//  MainFeedViewController.swift
//  FirebaseSocialApp
//
//  Created by Edrick Pascual on 8/6/16.
//  Copyright © 2016 Edge Designs. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper


class MainFeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        
    }
    
    // Tap gesture recognizer is linked to this action since the signout is an UIImage
    @IBAction func signOutTapped(_ sender: AnyObject) {
        let keyChainResult = KeychainWrapper.removeObjectForKey(KEY_UID)
        print("ED: ID Removed from keychain - \(keyChainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
}

extension MainFeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "postTableViewCell") as! PostTableViewCell
        
    }
    
    
    
}
