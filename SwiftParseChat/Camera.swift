//
//  Camera.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/28/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import MobileCoreServices

class Camera {
    
    class func shouldStartCamera(target: AnyObject, canEdit: Bool) -> Bool {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            return false
        }
        
        let type = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        let available = contains(UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.Camera) as [String]!, type)
        
        if available {
            imagePicker.mediaTypes = [type]
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
            
            if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear) {
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Rear
            } else if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front) {
                imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.Front
            }
        } else {
            return false
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.showsCameraControls = true
        imagePicker.delegate = target as ChatViewController
        target.presentViewController(imagePicker, animated: true, completion: nil)
        
        return true
    }

    class func shouldStartPhotoLibrary(target: AnyObject, canEdit: Bool) -> Bool {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) && !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            return false
        }
        
        let type = kUTTypeImage as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) && contains(UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.PhotoLibrary) as [String]!, type) {
            imagePicker.mediaTypes = [type]
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) && contains(UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.SavedPhotosAlbum) as [String]!, type) {
            imagePicker.mediaTypes = [type]
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        }
        else {
            return false
        }
        
        imagePicker.allowsEditing = canEdit
        if target is ChatViewController {
            imagePicker.delegate = target as ChatViewController
        } else if target is ProfileViewController {
            imagePicker.delegate = target as ProfileViewController
        }
        target.presentViewController(imagePicker, animated: true, completion: nil)
        
        return true
    }
    
    class func shouldStartVideoLibrary(target: AnyObject, canEdit: Bool) -> Bool {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) && !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            return false
        }
        
        let type = kUTTypeMovie as String
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) && contains(UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.PhotoLibrary) as [String]!, type) {
            imagePicker.mediaTypes = [type]
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) && contains(UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.SavedPhotosAlbum) as [String]!, type) {
            imagePicker.mediaTypes = [type]
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
        }
        else {
            return false
        }
        
        imagePicker.allowsEditing = canEdit
        imagePicker.delegate = target as ChatViewController
        target.presentViewController(imagePicker, animated: true, completion: nil)
        
        return true
    }
}