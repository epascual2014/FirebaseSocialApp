//
//  PhotoTaking.swift
//  FirebaseSocialApp
//
//  Created by Edrick Pascual on 8/7/16.
//  Copyright © 2016 Edge Designs. All rights reserved.
//

//
//  PhotoTakingHelper.swift
//  Letsrun
//
//  Created by Edrick Pascual on 7/12/16.
//  Copyright © 2016 Edge Designs. All rights reserved.
//

import UIKit

typealias PhotoTakingHelperCallback = (UIImage?) -> Void

class PhotoTakingHelper: NSObject {
    
    weak var viewController: UIViewController!
    var callback: PhotoTakingHelperCallback
    var imagePickerController: UIImagePickerController?
    
    init(viewController: UIViewController, callback: PhotoTakingHelperCallback) {
        self.viewController = viewController
        self.callback = callback
        
        super.init()
        
        showPhotoSourceSelection()
        
    }
    
    // Implementing photo taking method
    func showImagePickerController(sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController?.sourceType = sourceType
        imagePickerController?.delegate = self
        imagePickerController?.allowsEditing = true
        
        self.viewController.present(imagePickerController!, animated: true, completion: nil)
    }
    
    // MARK: Implementing the photo source selection popover
    func showPhotoSourceSelection() {
        
        // Allow user to choose between photo library and camera
        let alertController = UIAlertController(title: nil, message: "Location of your pictures", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .default) { (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
            
        }
        
        alertController.addAction(photoLibraryAction)
        
        // Only show camera option if rear camera is available
        if (UIImagePickerController.isCameraDeviceAvailable(.rear)) {
            let cameraAction = UIAlertAction(title: "Photo from Camera", style: .default) { (action) in
                self.showImagePickerController(sourceType: .camera)
            }
            alertController.addAction(cameraAction)
        }
        viewController.present(alertController, animated: true, completion: nil)
    }
    
}

extension PhotoTakingHelper: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Method to pick image
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [NSObject: AnyObject]!) {
        viewController.dismiss(animated: false, completion: nil)
        callback(image)
    }
    
    // Method to cancelling the picker method
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
}
