//
//  MyLocationManager.swift
//  tukumokkumokku
//
//  Created by kazu on 9/20/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import CoreLocation
import Foundation
import UIKit

class CommonUtil: NSObject {
  public static func checkLocationPermission(_ viewController: UIViewController, manager: CLLocationManager, status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      break
    case .notDetermined:
      manager.requestWhenInUseAuthorization()
      break
    case .denied:
      showAlert(viewController, title: "位置情報が拒否されています", message: "「設定」から、位置情報へのアクセスを許可してください。", handler: nil)
      break
    case .restricted:
      showAlert(viewController, title: "位置情報サービスがオフになっています", message: "「設定」から、位置情報サービスを有効にしてください。", handler: nil)
    }
  }

  public static func showAlert(_ viewController: UIViewController, title: String, message: String, handler: ((UIAlertAction) -> Void)?) {
    let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: handler)
    controller.addAction(action)
    viewController.present(controller, animated: true)
  }
}
