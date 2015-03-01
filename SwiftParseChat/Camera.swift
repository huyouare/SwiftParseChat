//
//  Camera.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 2/28/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import UIKit
import MobileCoreServices

func shouldStartCamera(target: AnyObject, canEdit: Bool) -> Bool {
    
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
