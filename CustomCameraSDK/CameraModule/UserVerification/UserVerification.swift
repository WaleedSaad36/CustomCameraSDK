//
//  UserVerification.swift
//  CustomCameraSDK
//
//  Created by Waleed Saad on 10/03/2024.
//

import UIKit

public func beginVerification(
    from presenter: (UIViewController & ValifyResultDelegate),
    with style: PresentationStyle = .present,
    animated: Bool = true
) {
  let viewController = CustomCameraController()
  viewController.valifyResultDelegat = presenter
  
  switch style {
  case .push:
    presenter.navigationController?.pushViewController(viewController, animated: animated)
      
  case .present:
      presenter.present(viewController, animated: animated, completion: nil)
      presenter.modalPresentationStyle = .fullScreen
  }
}

// MARK: - Presentation Style
//
public enum PresentationStyle {
  case push
  case present
}
