//
//  Images.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 3/2/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import Foundation

class Images {
    
    class func squareImage(image: UIImage, size: CGFloat) -> UIImage? {
        var cropped: UIImage!
        if (image.size.height > image.size.width)
        {
            let ypos = (image.size.height - image.size.width) / 2
            cropped = self.cropImage(image, x: 0, y: ypos, width: image.size.width, height: image.size.height)
        }
        else
        {
            let xpos = (image.size.width - image.size.height) / 2
            cropped = self.cropImage(image, x: xpos, y: 0, width: image.size.width, height: image.size.height)
        }
        
        let resized = self.resizeImage(cropped, width: size, height: size)

        return resized
    }
    
    class func resizeImage(var image: UIImage, width: CGFloat, height: CGFloat) -> UIImage? {
        var size = CGSizeMake(width, height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func cropImage(image: UIImage, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIImage? {
        let rect = CGRectMake(x, y, width, height)

        let imageRef = CGImageCreateWithImageInRect(image.CGImage, rect)
        let cropped = UIImage(CGImage: imageRef)

        return cropped
    }
}
