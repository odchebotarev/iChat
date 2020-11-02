//
//  UIImage+Extension.swift
//  iChat
//
//  Created by Oleg Chebotarev on 24.10.2020.
//

import UIKit

extension UIImage {
    
    var scaledToSafeUploadSize: UIImage? {
        
        let maxImageSideLength: CGFloat = 480
        
        let largerSide: CGFloat = max(size.width, size.height)
        let ratioScale: CGFloat = largerSide > maxImageSideLength ? largerSide / maxImageSideLength : 1
        let newImageSize = CGSize(width: size.width / ratioScale, height: size.height / ratioScale)
        
        return image(scaledTo: newImageSize)
    }
    
    func image(scaledTo size: CGSize) -> UIImage? {
        
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}
