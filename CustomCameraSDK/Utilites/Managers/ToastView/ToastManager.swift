//
//  ToastManager.swift
//  CustomCameraSDK
//
//  Created by Waleed Saad on 10/03/2024.
//

import UIKit

class ToastLabelFactory {
    static func makeToastLabel() -> UILabel {
        let toastLabel = UILabel()
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 18)
        toastLabel.textColor = UIColor.white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.numberOfLines = 0
        return toastLabel
    }
}

protocol ToastPresentable {
    func present(in view: UIView, message: String, duration: TimeInterval)
}

class ToastManager {
    static let shared = ToastManager()

    private init() {}

    func showToastPresenter() -> ToastPresentable {
        return DefaultToastPresenter(factory: ToastLabelFactory())
    }
}

class DefaultToastPresenter: ToastPresentable {
    private let factory: ToastLabelFactory

    init(factory: ToastLabelFactory) {
        self.factory = factory
    }

    func present(in view: UIView, message: String, duration: TimeInterval) {
        guard let window = UIApplication.shared.keyWindow else { return }

        let toastLabel = ToastLabelFactory.makeToastLabel()
        toastLabel.text = message

        let labelSize = calculateLabelSize(for: toastLabel, in: window)
        positionAndStyle(toastLabel, size: labelSize, window: window)

        window.addSubview(toastLabel)

        UIView.animate(withDuration: duration, animations: {
            toastLabel.alpha = 0
        }) { _ in
            toastLabel.removeFromSuperview()
        }
    }

    private func calculateLabelSize(for label: UILabel, in window: UIWindow) -> CGSize {
        let maxSize = CGSize(width: window.frame.width - 40, height: CGFloat.greatestFiniteMagnitude)
        return label.sizeThatFits(maxSize)
    }

    private func positionAndStyle(_ label: UILabel, size: CGSize, window: UIWindow) {
        let adjustedHeight = max(size.height + 20, 30) // Adjusted height with a minimum value of 30
        let labelWidth = min(size.width, window.frame.width - 40)
        
        // Change the y-coordinate to position the label at the top
        label.frame = CGRect(x: 20, y: 90, width: labelWidth + 20, height: adjustedHeight)
        label.center.x = window.center.x
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
    }
}
