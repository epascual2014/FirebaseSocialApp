//
//  Post.swift
//  FirebaseSocialApp
//
//  Created by Edrick Pascual on 8/7/16.
//  Copyright © 2016 Edge Designs. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    private var _postRef: FIRDatabaseReference!
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _username: String!
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var username: String {
        return _username
    }
    
    init(caption: String, imageUrl: String, likes: Int, username: String) {
        self._caption = caption
        self._imageUrl = caption
        self._likes = likes
        self._username = username
    }
    
    // Pass data to Firebase 
    init(postKey: String, postData: [String: AnyObject]) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String{
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let username = postData["username"] as? String {
            self._username = username
        }
        
        _postRef = DataSource.dataSource.REF_POSTS.child(_postKey)
    }
    
    // Add or remove likes
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        _postRef.child("likes").setValue(_likes)
    }
    
}
