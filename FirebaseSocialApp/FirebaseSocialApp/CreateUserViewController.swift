//
//  CreateUserViewController.swift
//  FirebaseSocialApp
//
//  Created by Edrick Pascual on 8/8/16.
//  Copyright © 2016 Edge Designs. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper


class CreateUserViewController: UIViewController {

    @IBOutlet weak var userImageview: CircleView!
    @IBOutlet weak var usernameTextfield: CustomTextfield!
    @IBOutlet weak var userEmailTextfield: CustomTextfield!
    @IBOutlet weak var userPasswordTextfield: CustomTextfield!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: Create user
    func createUser() {
        if let email = userEmailTextfield.text, let password = userPasswordTextfield.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    print("ED: Unable to auth Firebase w/ Email")
                    self.loginErrorAlert(title: "Oops!", message: "Having some trouble creating your account. Please try again.")
                } else {
                    print("ED: Successfull auth with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        // TO DO add username
                        //let user = ["provider": authData.provider!, "email": email!, "username": username!]
                        
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                    
                }
            })
        }
    }
    
    // Uses Keychain Framework to save user IDs
    func completeSignIn(id: String, userData: [String: AnyObject]) {
        DataSource.dataSource.createFirebaseUser(uid: id, userData: userData)
        let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
        print("ED: Data saved to keychain - \(keychainResult)")
        performSegue(withIdentifier: "goToMain", sender: nil)
    }

    
    
    // MARK: Login Error Message
    func loginErrorAlert(title: String, message: String) {
        // If login does not work call error message
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    


}
