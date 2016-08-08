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


class MainFeedViewController: UIViewController  {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addImageView: CircleView!
    
    // Var referencing Post class
    var posts = [Post]()

    // Initialize UIImagepicker Controller
    var imagePicker: UIImagePickerController!
    
    // Global
    static var imageCache: NSCache<NSString, UIImage> = NSCache()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // initializing imagepicker controller
        self.imagePicker = UIImagePickerController()
        // Allows user to resize image
        self.imagePicker.allowsEditing = true
        self.imagePicker.delegate = self
        
        
        // Reference the Firebase database Class DataSource
        DataSource.dataSource.REF_POSTS.observe(.value, with: { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDictionary = snap.value as? [String: AnyObject] {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDictionary)
                        self.posts.append(post)
                        
                        
                    }
                }
                
            }
            self.tableView.reloadData()
        })
    }
    
    // Tap gesture recognizer is linked to this action since the signout is an UIImage
    @IBAction func signOutTapped(_ sender: AnyObject) {
        let keyChainResult = KeychainWrapper.removeObjectForKey(KEY_UID)
        print("ED: ID Removed from keychain - \(keyChainResult)")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
}

extension MainFeedViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "postTableViewCell") as? PostTableViewCell {
            
            if let image = MainFeedViewController.imageCache.object(forKey: post.imageUrl) {
                cell.configureCell(post: post, image: image)
                return cell
            } else {
                cell.configureCell(post: post)
                return cell
            }
        } else {
            return PostTableViewCell()
        }
    }
}

extension MainFeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImageView.image = image
        } else {
            print("ED: A valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}

