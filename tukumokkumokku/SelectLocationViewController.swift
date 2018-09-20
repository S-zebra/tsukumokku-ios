//
//  SelectLocationViewController.swift
//  tukumokkumokku
//
//  Created by kazu on 9/20/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import CoreLocation
import MapKit
import UIKit

class SelectLocationViewController: UIViewController, UIGestureRecognizerDelegate {
  @IBOutlet var currentLocationButton: UIBarButtonItem!
  @IBOutlet var mapView: MKMapView!
  @IBOutlet var panGestureRcg: UIPanGestureRecognizer!

  var locationManager: CLLocationManager!
  var currentLocation: CLLocationCoordinate2D!
  var annotation: MKPointAnnotation!
  var trace = false

//  var autoChase: Bool = False

  override func viewDidLoad() {
    super.viewDidLoad()
    annotation = MKPointAnnotation()
    // Do any additional setup after loading the view.

    panGestureRcg.addTarget(self, action: #selector(onMapPanned(_:)))
    panGestureRcg.delegate = self

    // 位置情報サービス初期化
    locationManager = CLLocationManager()
    locationManager.delegate = self

    // 磁石の精度設定
    locationManager.headingFilter = kCLHeadingFilterNone
    locationManager.headingOrientation = .portrait
  }

  override func viewDidAppear(_ animated: Bool) {
    // 画面真ん中にピンを置く
    setMapCenterAndPin(coordinate: mapView.region.center)
    // トレーサー起動
    mapView.addAnnotation(annotation)
    mapView.addGestureRecognizer(panGestureRcg)
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

  @IBAction func onCurrentLocationButtonClick(_ sender: Any) {
    // トレーサー再開
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
    trace = true
  }

  @objc func onMapPanned(_ sender: Any) {
    // マップをパンしたとき: ユーザーの操作に任せる
    NSLog("Map is panned")
    setMapCenterAndPin(coordinate: mapView.region.center)
    locationManager.stopUpdatingLocation()
    locationManager.stopUpdatingHeading()
    trace = false
  }

  func setMapCenterAndPin(coordinate: CLLocationCoordinate2D) {
    if trace {
      mapView.region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.005, 0.005))
    }
    annotation.coordinate = coordinate
    annotation.title = "現在地"
    annotation.subtitle = String(format: "%.3f %.3f", coordinate.latitude, coordinate.longitude)
    NSLog("Locations is set to %.4f, %.4f", coordinate.latitude, coordinate.latitude)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension SelectLocationViewController: CLLocationManagerDelegate {
  // 位置情報の更新時
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations[0].coordinate
    NSLog("Lat: %.4f, Lon: %.4f", currentLocation.latitude, currentLocation.longitude)
    setMapCenterAndPin(coordinate: currentLocation)
  }

  // 方位の更新時
  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    NSLog("Heading Updated: %s", newHeading.description)
  }
}
