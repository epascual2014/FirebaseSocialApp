//
//  PostTableViewCell.swift
//  FirebaseSocialApp
//
//  Created by Edrick Pascual on 8/6/16.
//  Copyright © 2016 Edge Designs. All rights reserved.
//

import UIKit
import Firebase

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likeImageView: UIImageView!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImageView.addGestureRecognizer(tap)
        likeImageView.isUserInteractionEnabled = true
    }
    
    func configureCell(post: Post, image: UIImage? = nil) {
        self.post = post
        // Get reference from Firebase
        likesRef = DataSource.dataSource.REF_USER_CURRENT.child("likes").child(post.postKey)
        self.captionTextView.text = post.caption
        self.likesLabel.text = "\(post.likes)"
        
        if image != nil {
            self.postImageView.image = image
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion:  { (data, error) in
                if error != nil {
                    print("ED: Unable to download image from FIR storage")
                } else {
                    print("ED: Image download from FIR storage")
                    if let imageData = data {
                        if let image = UIImage(data: imageData) {
                            self.postImageView.image = image
                            MainFeedViewController.imageCache.setObject(image, forKey: post.imageUrl)
                        }
                        
                    }
                }
            })
        }
        
       
        likesRef.observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
            if let snapshot = snapshot.value as? NSNull {
                self.likeImageView.image = UIImage(named: "empty-heart")
            } else {
                self.likeImageView.image = UIImage(named: "filled-heart")
            }
        })
    }
    
    // MARK: Like button
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot: FIRDataSnapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeImageView.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                
                // Adding like reference to Firebase
                self.likesRef.setValue(true)
            } else {
                self.likeImageView.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                
                // Removing like reference from Firebase
                self.likesRef.removeValue()
            }
        })
    }
}
