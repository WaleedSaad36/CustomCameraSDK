//
//  CustomCamera.swift
//  CustomCameraSDK
//
//  Created by Waleed Saad on 10/03/2024.
//

import Foundation
import UIKit
import AVFoundation
import Vision

class CustomCameraController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // MARK: - Variables
    //
    lazy private var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    lazy private var takePhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.shutter.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleTakePhoto), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()
    private let photoOutput = AVCapturePhotoOutput()
    private var captureSession = AVCaptureSession()
    private lazy var toastView = ToastManager.shared.showToastPresenter()
    weak var valifyResultDelegat: ValifyResultDelegate?
    
    // MARK: - View LifeCycle Methods
    //
    override func viewDidLoad() {
        super.viewDidLoad()
        FaceDetectionManager.shared.addObserver(self)
        openCamera()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopCameraIfNeeded()
    }
    
    deinit {
        FaceDetectionManager.shared.removeObserver(self)
        stopCameraIfNeeded()
    }
    
  
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(), let previewImage = UIImage(data: imageData) else { return }
        stopCameraIfNeeded()
        
        let photoPreviewContainer = PhotoPreviewView(frame: self.view.frame)
        photoPreviewContainer.photoImageView.image = flipImage(previewImage)
        photoPreviewContainer.delegate = self
        self.view.addSubviews(photoPreviewContainer)
    }
    
    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        FaceDetectionManager.shared.detectFaces(in: pixelBuffer)
    }
}

//MARK: - setup Camera
//
private extension CustomCameraController {
    
    func stopCameraIfNeeded() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    func startCameraIfNeeded() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    func openCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // the user has already authorized to access the camera.
            self.setupCaptureSession()
            
        case .notDetermined: // the user has not yet asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { (granted) in
                if granted { // if user has granted to access the camera.
                    print("the user has granted to access the camera")
                    DispatchQueue.main.async {
                        self.setupCaptureSession()
                    }
                } else {
                    print("the user has not granted to access the camera")
                    self.handleDismiss()
                }
            }
            
        case .denied:
            print("the user has denied previously to access the camera.")
            self.handleDismiss()
            
        case .restricted:
            print("the user can't give camera access due to some restriction.")
            self.handleDismiss()
            
        default:
            print("something has wrong due to we can't access the camera.")
            self.handleDismiss()
        }
    }
    
    func setupCaptureSession() {
        
        guard let captureDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {
            print("Error: no video devices available")
            return
        }
        
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch let error {
            print("Failed to set input device with error: \(error)")
            return
        }
        
        // Add photo output
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        photoOutput.maxPhotoQualityPrioritization = .balanced
        // Add video data output for face detection
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        
        let cameraLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraLayer.frame = self.view.frame
        cameraLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(cameraLayer)
        
        captureSession.startRunning()
        self.setupUI()
    }
    
}



//MARK: - Conform FaceDetectionObserver
//
extension CustomCameraController: FaceDetectionObserver {
    // Implement the FaceDetectionObserver methods
    func didDetectFaces(_ numberOfFaces: Int) {
        // Update UI or perform actions based on face detection results
        print("Detected \(numberOfFaces) face(s)")
        takePhotoButton.isUserInteractionEnabled = (numberOfFaces == 1)
        if numberOfFaces == 1  {
            toastView.present(in: self.view, message: "Ready for capture", duration: 1)
        } else if numberOfFaces > 1 {
            toastView.present(in: self.view, message: "We need only one face", duration: 1)
        } else {
            toastView.present(in: self.view, message: "no face found", duration: 1)

        }
        
    }
    
    func didFailFaceDetection(withError error: Error) {
        // Handle face detection failure
        print("Failed to detect faces:", error)
        toastView.present(in: self.view, message: "Failed to detect faces", duration: 1)
    }
}


//MARK: - Setup UI + Actions
private extension CustomCameraController {
     func setupUI() {
        
        view.addSubviews(backButton, takePhotoButton)
        
        takePhotoButton.makeConstraints(
            top: nil,
            left: nil,
            right: nil,
            bottom: view.safeAreaLayoutGuide.bottomAnchor,
            topMargin: 0,
            leftMargin: 0,
            rightMargin: 0,
            bottomMargin: 15,
            width: 80,
            height: 80
        )
        takePhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        backButton.makeConstraints(
            top: view.safeAreaLayoutGuide.topAnchor,
            left: nil,
            right: view.rightAnchor,
            bottom: nil,
            topMargin: 15,
            leftMargin: 0,
            rightMargin: 10,
            bottomMargin: 0,
            width: 50,
            height: 50
        )
    }
    
    @objc private func handleDismiss() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func handleTakePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
            photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
}

extension CustomCameraController: PhotoPreviewDelegate {
    func didTapApprovPhoto(photo: UIImage) {
        valifyResultDelegat?.didFinishCapturePhoto(to: self, with: .success(photo))
        self.dismiss(animated: true)
    }
    
    func didShowPreview() {
        stopCameraIfNeeded()
    }
    
    func didTapReCapturePhoto() {
        startCameraIfNeeded()
    }
    func showErrorMessage(message: String) {
        UIAlertController.presentCustomAlert(in: self, message: message, close: nil) {
            self.startCameraIfNeeded()
        }
    }
}
