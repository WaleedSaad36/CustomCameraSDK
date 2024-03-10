//
//  PhotoQualityValidator.swift
//  CustomCameraSDK
//
//  Created by Waleed Saad on 10/03/2024.
//

import UIKit


class PhotoQualityValidator: PhotoQualityValidatorProtocol {
    func validate(photo: UIImage) throws {
        try checkQuality(photo: photo)
    }
}

private extension PhotoQualityValidator {
    func checkQuality(photo: UIImage) throws {
        guard isHighQuality(photo: photo) else {
            throw PhotoQualityError.lowQuality
        }
    }
    
    func isHighQuality(photo: UIImage, minimumResolution: CGFloat = 1800, minimumFileSize: Int = 500000) -> Bool {
       
        guard let imageData = photo.jpegData(compressionQuality: 1.0) else {
              print("Failed to get JPEG data")
              return false
          }

          let imageSize = photo.size
          let imageResolution = max(imageSize.width, imageSize.height)
          let fileSize = imageData.count
        
          let isHighQuality = imageResolution >= minimumResolution && fileSize >= minimumFileSize
          return isHighQuality
    }
}
