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
    @IBOutlet weak var addCaptionTextfield: CustomTextfield!

    // Var referencing Post class
    var posts = [Post]()

    // Initialize UIImagepicker Controller
    var imagePicker: UIImagePickerController!
    
    // Global
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    // Since the selecting image is an image not a button, we have to say that its not an image.
    var imageSelected = false

    
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
            // Reload data to refresh view
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
    
    // MARK: Select image button
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: Post selected image button
    @IBAction func postImageTapped(_ sender: AnyObject) {
        // User must add a caption
        guard let caption = addCaptionTextfield.text, caption != "" else {
            print("ED: Caption must be entered")
            
            return
        }
        //  User must select an image
        guard let image = addImageView.image, imageSelected == true else {
            print("ED: Please select an image")
            
            return
        }
        // MARK: Uncompressing image data to reduce file size
        if let imageData = UIImageJPEGRepresentation(image, 0.2) {
            
            // Create an ID for image to pass into Firebase storage
            // MARK: Create a unique IDENTIFIER ID
            let imageUid = NSUUID().uuidString
            
            // Initialize - FIREBASE STORAGE METADATA and content type
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            // Putting image data in FIREBASE STORAGE
            DataSource.dataSource.REF_POST_IMAGES.child(imageUid).put(imageData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("ED: Unable to upload image to FIR Storage")
                } else {
                    print("ED: Successfully  uploaded image to FIR Storage")
                    
                    // MARK: URL of metadata in FIREBASE Storage
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    
                    if let url = downloadURL {
                        self.postToFirebase(imageUrl: url)
                    }
                    
                }
            }
        }
    }
    
    // MARK: Posting caption and images to Firebase by assigning the elements.
    func postToFirebase(imageUrl: String) {
        let post: [String:AnyObject] = ["caption": addCaptionTextfield.text!, "imageUrl": imageUrl, "likes": 0]
        let firebasePost = DataSource.dataSource.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        // Assign elements
        addCaptionTextfield.text = ""
        imageSelected = false
        addImageView.image = UIImage(named: "add-image")
        
        // Refresh tableview to show new posts and captions
        tableView.reloadData()
    }
    
    
}


// MARK: Extension TableViewDataSource and Delegates
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

// MARK: Extension UIImagePickerController
extension MainFeedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImageView.image = image
            imageSelected = true
        } else {
            print("ED: A valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
}

