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
    
    var post: Post!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configureCell(post: Post, image: UIImage? = nil) {
        self.post = post
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
    }
}
