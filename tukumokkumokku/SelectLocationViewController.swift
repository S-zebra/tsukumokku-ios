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
  @IBOutlet var currentLocationButton: UIButton!
  @IBOutlet var currentLocationLabel: UILabel!
  @IBOutlet var mapView: MKMapView!
  @IBOutlet var panGestureRcg: UIPanGestureRecognizer!

  var locationManager: CLLocationManager!
  var currentLocation: CLLocationCoordinate2D!
  var annotation: MKPointAnnotation!
  var trace = false

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
    mapView.addAnnotation(annotation)

    // ジェスチャー認識開始
    mapView.addGestureRecognizer(panGestureRcg)

    // 位置情報取得開始
    onCurrentLocationButtonClick("_")
  }

  @IBAction func onCurrentLocationButtonClick(_ sender: Any) {
    // 位置情報の取得再開
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
    trace = true
    currentLocationButton.isSelected = true
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    // パン操作を優先的にキャッチする
    return true
  }

  @objc func onMapPanned(_ sender: Any) {
    // マップがパンされたときは追跡を中止する
    NSLog("Map is panned")
    setMapCenterAndPin(coordinate: mapView.region.center)
    locationManager.stopUpdatingLocation()
    locationManager.stopUpdatingHeading()
    trace = false
    currentLocationButton.isSelected = false
  }

  func setMapCenterAndPin(coordinate: CLLocationCoordinate2D) {
    if trace {
      mapView.region = MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.005, 0.005))
    }
    annotation.coordinate = coordinate
    annotation.title = "この位置で確定"
    currentLocationLabel.text = String(format: "%.5f, %.5f", coordinate.latitude, coordinate.longitude)
    NSLog("Locations is set to %.4f, %.4f", coordinate.latitude, coordinate.longitude)
  }

  // 終了の処理
  @IBAction func onDoneButtonClick(_ sender: Any) {
    let postVC = presentingViewController as! PostViewController
    postVC.currentLocation = currentLocation
    postVC.geoLabel.text = currentLocationLabel.text
    dismiss(animated: true, completion: nil)
  }

  @IBAction func onCancelButtonClick(_ sender: Any) {
    dismiss(animated: true, completion: nil)
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
