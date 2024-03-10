//
//  FaceDetectionManagerProtocol.swift
//  CustomCameraSDK
//
//  Created by Waleed Saad on 10/03/2024.
//

import Foundation

protocol FaceDetectionObserver: AnyObject {
    func didDetectFaces(_ numberOfFaces: Int)
    func didFailFaceDetection(withError error: Error)
}
