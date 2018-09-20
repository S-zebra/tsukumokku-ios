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
  public static func checkLocationPermission(status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      break
    case .notDetermined:
      manager.requestWhenInUseAuthorization()
      break
    case .denied:
      showAlert(title: "位置情報が拒否されています", message: "「設定」から、位置情報へのアクセスを許可してください。")
      break
    case .restricted:
      showAlert(title: "位置情報サービスがオフになっています", message: "「設定」から、位置情報サービスを有効にしてください。")
    }
  }

  public static func showAlert(title: String, message: String) {
    let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    controller.addAction(action)
    present(controller, animated: true)
  }
}
