//
//  FaceDetectionManager.swift
//  CustomCameraSDK
//
//  Created by Waleed Saad on 10/03/2024.
//

import UIKit
import AVFoundation
import Vision


class FaceDetectionManager {
    static let shared = FaceDetectionManager()

    private var observers: [FaceDetectionObserver] = []

    private init() {}

    func addObserver(_ observer: FaceDetectionObserver) {
        observers.append(observer)
    }

    func removeObserver(_ observer: FaceDetectionObserver) {
        observers.removeAll { $0 === observer }
    }

    func detectFaces(in pixelBuffer: CVPixelBuffer) {
        let faceDetectionRequest = VNDetectFaceRectanglesRequest { [weak self] request, error in
            guard let self = self else { return }
            
            if let error = error {
                self.notifyObserversOfFailure(error)
                return
            }
            
            DispatchQueue.main.async {
                if let results = request.results {
                    let numberOfFaces = results.count
                    self.notifyObserversOfFaceDetection(numberOfFaces)
                }
            }
        }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            
            do {
                try imageRequestHandler.perform([faceDetectionRequest])
            } catch let requestError {
                self.notifyObserversOfFailure(requestError)
            }
        }
    }

    private func notifyObserversOfFaceDetection(_ numberOfFaces: Int) {
        observers.forEach { $0.didDetectFaces(numberOfFaces) }
    }

    private func notifyObserversOfFailure(_ error: Error) {
        observers.forEach { $0.didFailFaceDetection(withError: error) }

    }
}
