//
//  Images.swift
//  SwiftParseChat
//
//  Created by Jesse Hu on 3/2/15.
//  Copyright (c) 2015 Jesse Hu. All rights reserved.
//

import Foundation

class Images {
    
    class func resizeImage(var image: UIImage, width: CGFloat, height: CGFloat) -> UIImage {
        var size = CGSizeMake(width, height);
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.drawInRect(CGRectMake(0, 0, size.width, size.height));
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}
