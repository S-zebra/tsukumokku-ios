//
//  MapViewController.swift
//  tukumokkumokku
//
//  Created by kazu on 9/18/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class MapViewController: UIViewController {
  @IBOutlet var mapView: MKMapView!
  var locationManager: CLLocationManager!
  var currentLocation: CLLocationCoordinate2D?
  let zoomedSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    // Do any additional setup after loading the view.
  }

  override func viewDidAppear(_ animated: Bool) {
    locationManager.startUpdatingLocation()
    var newRegion = mapView.region
    newRegion.span = zoomedSpan
    mapView.setRegion(newRegion, animated: true)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      NSLog("Location allowed")
      break
    case .notDetermined:
      manager.requestWhenInUseAuthorization()
      break
    case .restricted:
      showAlert(title: "位置情報サービスが無効です", message: "現在地を取得できません。位置情報サービスを有効にしてください。")
      break
    case .denied:
      let appName: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
      showAlert(title: "位置情報にアクセスできません", message: "現在地を取得できません。「設定」から「\(appName ?? "このアプリ")」に位置情報へのアクセスを許可してください。")
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations[0].coordinate
    mapView.setCenter(currentLocation!, animated: true)
  }

  func showAlert(title: String, message: String) {
    let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    controller.addAction(action)
    present(controller, animated: true)
  }
}
