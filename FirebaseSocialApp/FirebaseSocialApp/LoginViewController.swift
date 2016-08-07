//
//  LoginViewController.swift
//  FirebaseSocialApp
//
//  Created by Edrick Pascual on 8/6/16.
//  Copyright © 2016 Edge Designs. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftKeychainWrapper

class LoginViewController: UIViewController {
    
    @IBOutlet weak var facebookButton: RoundButton!
    @IBOutlet weak var emailTextfield: CustomTextfield!
    @IBOutlet weak var passwordTextfield: CustomTextfield!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if KeychainWrapper.stringForKey(KEY_UID) != nil {
            performSegue(withIdentifier: "goToMain", sender: nil)
        }
        
    }
    
    @IBAction func facebookActionTapped(_ sender: AnyObject) {
        
        // Facebook Authentication
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("ED: UNABLE TO auth \(error)")
            } else if result?.isCancelled == true {
                print("ED: User cancelled FB Auth")
            } else {
                print("ED: Successful Facebook Auth")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                // Call Firebase Auth once we have the Facebook token
                self.firebaseAuth(credential)
            }
        }
    }
    
    // Firebase Authentication
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("ED: Unable to auth w/ Firebase - \(error)")
            } else {
                print("ED: Successful Firebase Auth")
                if let user = user {
                    self.completeSignIn(id: user.uid)
                }
            }
        })
    }
    
    // Signin Button
    @IBAction func signinButtonTapped(_ sender: AnyObject) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            
            // Firebase Authentication when user signs in
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("ED: Email user auth with Firebase")
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                   
                } else {
                    self.createUser()
                }
            })
        }
    }
    
    // If user is new, create user
    func createUser() {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    print("ED: Unable to auth Firebase w/ Email")
                } else {
                    print("ED: Successfull auth with Firebase")
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                    
                }
            })
        }
    }
    
    // Uses Keychain Framework to save user IDs
    func completeSignIn(id: String) {
        let keychainResult = KeychainWrapper.setString(id, forKey: KEY_UID)
        print("ED: Data saved to keychain - \(keychainResult)")
        performSegue(withIdentifier: "goToMain", sender: nil)
    }
    

    
    
}
