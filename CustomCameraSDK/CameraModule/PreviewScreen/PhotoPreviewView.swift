//
//  PhotoPreview.swift
//  CustomCameraSDK
//
//  Created by Waleed Saad on 10/03/2024.
//

import UIKit

protocol PhotoPreviewDelegate: AnyObject {
    func didShowPreview()
    func didTapReCapturePhoto()
    func didTapApprovPhoto(photo: UIImage)
    func showErrorMessage(message: String)
}

class PhotoPreviewView: UIView {
    //MARK: - Properties
    //
    let photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .clear
        stackView.spacing = 15
        return stackView
    }()
    
    private lazy var reCaptureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Recapture", for: .normal)
        button.backgroundColor = .red
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(didTappedReCaptureButton), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    private lazy var approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Approve", for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(didTappedApporovButton), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    private var photoQualityValidator: PhotoQualityValidatorProtocol = PhotoQualityValidator()

    weak var delegate: PhotoPreviewDelegate?
    weak var valifyResultDelegate: ValifyResultDelegate?
    
    
    //MARK: - initializers
    //
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

//MARK: - UI + Actions
//
private extension PhotoPreviewView {
    func setupUI() {
        addSubviews(photoImageView, cancelButton)
        
        photoImageView.makeConstraints(
            top: topAnchor,
            left: leftAnchor,
            right: rightAnchor,
            bottom: bottomAnchor,
            topMargin: 0,
            leftMargin: 0,
            rightMargin: 0,
            bottomMargin: 0,
            width: 0,
            height: 0
        )
        
        cancelButton.makeConstraints(
            top: safeAreaLayoutGuide.topAnchor,
            left: nil,
            right: rightAnchor,
            bottom: nil,
            topMargin: 15,
            leftMargin: 0,
            rightMargin: 10,
            bottomMargin: 0,
            width: 50,
            height: 50
        )
        
        
        horizontalStackView.makeConstraints(
            top: nil,
            left: nil,
            right: nil ,
            bottom: nil,
            topMargin: 0,
            leftMargin: 20,
            rightMargin: 20,
            bottomMargin: 30,
            width: 0,
            height: 0
        )
        
        addSubviews(horizontalStackView)
        horizontalStackView.makeConstraints(
            top: nil,
            left: safeAreaLayoutGuide.leftAnchor,
            right: safeAreaLayoutGuide.rightAnchor,
            bottom: safeAreaLayoutGuide.bottomAnchor,
            topMargin: 0,
            leftMargin: 20,
            rightMargin: 20,
            bottomMargin: 15,
            width: 0,
            height: 50
        )
        horizontalStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        horizontalStackView.addArrangedSubview(reCaptureButton)
        horizontalStackView.addArrangedSubview(approveButton)
    }
    
    @objc private func handleCancel() {
        DispatchQueue.main.async {
            self.removeFromSuperview()
            self.delegate?.didTapReCapturePhoto()
            
        }
    }
    
    @objc private func didTappedReCaptureButton() {
        DispatchQueue.main.async {
            self.removeFromSuperview()
            self.delegate?.didTapReCapturePhoto()
        }
    }
    
    @objc private func didTappedApporovButton() {
        DispatchQueue.main.async {
            self.removeFromSuperview()
            guard let photo = self.photoImageView.image else { return }
            
            do {
                try self.photoQualityValidator.validate(photo: photo)
                self.delegate?.didTapApprovPhoto(photo: photo)
            } catch PhotoQualityError.lowQuality {
                self.showLowQualityAlert()
            } catch {
                print("Unexpected error: \(error)")
            }
        }
    }
}

private extension PhotoPreviewView {
    func showLowQualityAlert() {
        delegate?.showErrorMessage(message: "low quality photo\n please try again")
    }
}
