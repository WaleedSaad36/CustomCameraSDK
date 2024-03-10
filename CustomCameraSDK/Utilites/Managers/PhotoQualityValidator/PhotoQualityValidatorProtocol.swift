//
//  PhotoQualityValidatorProtocol.swift
//  CustomCameraSDK
//
//  Created by Waleed Saad on 10/03/2024.
//

import UIKit

enum PhotoQualityError: Error {
    case lowQuality
}

protocol PhotoQualityValidatorProtocol {
    func validate(photo: UIImage) throws
}
