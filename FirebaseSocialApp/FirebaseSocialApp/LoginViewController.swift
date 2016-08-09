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
    
        // Stores user ID so user does not need to sign in if they are already a user.
        if KeychainWrapper.stringForKey(KEY_UID) != nil {
            performSegue(withIdentifier: "goToMain", sender: nil)
        }
        
    }
    
    // MARK: Authentication for Facebook
    @IBAction func facebookActionTapped(_ sender: AnyObject) {
        
        // Authenticating for FACEBOOK
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
    
    // Authenticating for Firebase
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("ED: Unable to auth w/ Firebase - \(error)")
            } else {
                print("ED: Successful Firebase Auth")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    // Once Firebase is authenticated go ahead and sign in
                    self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }
    
    // MARK: Signin user
    @IBAction func signinButtonTapped(_ sender: AnyObject) {
        if let email = emailTextfield.text, let password = passwordTextfield.text {
            
            // Firebase Authentication when user signs in
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("ED: Email user auth with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    } else {
                        self.loginErrorAlert(title: "Oops!", message: "Having some trouble creating your account. Please try again.")
                    }
                }
            })
        }
    }
    
    @IBAction func registerTappedButton(_ sender: AnyObject) {
        // Not a user, create new user
        performSegue(withIdentifier: "goToCreateUser", sender: nil)
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
