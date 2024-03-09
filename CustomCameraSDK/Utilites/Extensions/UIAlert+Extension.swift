//
//  UIAlert+Extension.swift
//  CustomCameraSDK
//
//  Created by Waleed Saad on 10/03/2024.
//

import UIKit

extension UIAlertController {
    static func presentCustomAlert(
        in viewController: UIViewController,
        title: String? = "Error",
        message: String?,
        close: (()->())? = nil,
        action: @escaping (()->()),
        actionTitle: String? = "OK"
    ) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let _action = UIAlertAction(title: actionTitle, style: .default) { _ in
            action()
        }
        alertController.addAction(_action)
        viewController.present(alertController, animated: true)
    }
}
