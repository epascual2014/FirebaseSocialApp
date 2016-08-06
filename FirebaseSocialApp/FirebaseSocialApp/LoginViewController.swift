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

class LoginViewController: UIViewController {

    @IBOutlet weak var facebookButton: RoundButton!
    
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
            }
        })
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
