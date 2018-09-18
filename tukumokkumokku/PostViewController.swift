//
//  PostViewController.swift
//  tukumokkumokku
//
//  Created by kazu on 9/17/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import CoreLocation
import UIKit

class PostViewController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate {
  @IBOutlet var contentBox: UITextView!
  @IBOutlet var geoButton: UIButton!
  @IBOutlet var geoRetrievingIndicator: UIActivityIndicatorView!
  @IBOutlet var geoLabel: UILabel!

  var currentLocation: CLLocationCoordinate2D!

  var locationManager: CLLocationManager!
  var api: TsukumoAPI!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    api = TsukumoAPI.shared
  }

  @IBAction func geoButtonClick(_ sender: Any) {
    // 位置情報サービス初期化
    locationManager = CLLocationManager()
    locationManager.delegate = self
    // 起動
    locationManager.startUpdatingLocation()

    geoButton.isEnabled = false
    geoRetrievingIndicator.startAnimating()
    geoLabel.isHidden = false
  }

  // 更新時
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations[0].coordinate
    NSLog("Lat: %.4f, Lon: %.4f", currentLocation.latitude, currentLocation.longitude)
    locationManager.stopUpdatingLocation()
    geoButton.setImage(UIImage(named: "baseline_location_on_black_24pt"), for: .normal)
    geoButton.isEnabled = true
    geoRetrievingIndicator.stopAnimating()
    geoLabel.text = String(format: "%.3f, %.3f", currentLocation.latitude, currentLocation.longitude)
  }

  @IBAction func onCancelButtonClick(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func onSendButtonClick(_ sender: Any) {
    if currentLocation == nil { NSLog("Location is not set!") }
    do {
      NSLog("Location OK, calling sendPost()")
      try api.sendPost(lat: Float(currentLocation.latitude),
                       lon: Float(currentLocation.longitude),
                       text: contentBox.text,
                       onComplete: {
                         NSLog("Post Complete!")
                         DispatchQueue.main.async {
                           self.dismiss(animated: true, completion: nil)
                         }
      })
    } catch {
      NSLog("Encoding Error")
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // CLLocation初期化 (ボタンを押された時)
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .notDetermined:
      NSLog("未許可")
      locationManager.requestWhenInUseAuthorization()
      break
    case .restricted:
      NSLog("OSレベルで無効化されている？")
      break
    case .denied:
      NSLog("拒否されている")
      break
    case .authorizedAlways:
      NSLog("バック含め許可されている")
      break
    case .authorizedWhenInUse:
      NSLog("FG時のみ許可されている")
    }
  }
}
