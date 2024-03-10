//
//  ValifyResultDelegate.swift
//  CustomCameraSDK
//
//  Created by Waleed Saad on 10/03/2024.
//

import UIKit

public protocol ValifyResultDelegate: AnyObject {
    func didFinishCapturePhoto(to viewController: UIViewController, with result: Result<UIImage, Error>)
}
