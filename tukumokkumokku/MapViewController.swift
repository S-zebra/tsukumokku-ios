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
  @IBOutlet var panGestureRcg: UIPanGestureRecognizer!
  @IBOutlet var currentLocationButton: UIButton!
  @IBOutlet var toastBox: UIVisualEffectView!
  @IBOutlet var toastLabel: UILabel!
  @IBOutlet var putButton: UIButton!

  var locationManager: CLLocationManager!
  var currentLocation: CLLocationCoordinate2D?
  var notifiers = [UILocalNotification]()
  let api = TsukumoAPI.shared

  var pinPostDict: Dictionary<Int, Post>!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    pinPostDict = Dictionary()
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    mapView.delegate = self
    mapView.showsUserLocation = true
    panGestureRcg.delegate = self
    panGestureRcg.addTarget(self, action: #selector(onMapPanned(_:)))
    putButton.isHidden = (TsukumoAPI.getStoredPost() == nil)
  }

  override func viewDidAppear(_ animated: Bool) {
    locationManager.startUpdatingLocation()
    let newRegion = MKCoordinateRegionMake(mapView.region.center,
                                           MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    mapView.setRegion(newRegion, animated: false)
    updatePosts()
    showToast(text: "現在地を追跡しています", duration: Constants.TOAST_LENGTH_SHORT)
  }

  @objc func onMapPanned(_ sender: Any) {
    currentLocationButton.isSelected = false
  }

  @IBAction func currentLocationButtonTapped(_ sender: Any) {
    currentLocationButton.isSelected = true
    if currentLocation != nil {
      mapView.setRegion(MKCoordinateRegionMake(currentLocation!,
                                               mapView.region.span),
                        animated: true)
    }
  }

  @IBAction func refreshButtonTappeed(_ sender: Any) {
    updatePosts()
  }

  func setPutButtonVisibility(visible: Bool) {
    putButton.isHidden = !visible
  }

  @IBAction func putButtonTapped(_ sender: Any) {
    do {
      try api.addLocation(postId: TsukumoAPI.getStoredPost()!.id, location: currentLocation!, onComplete: {
        DispatchQueue.main.async {
          self.showToast(text: "投稿を置きました。", duration: Constants.TOAST_LENGTH_SHORT)
          UserDefaults().removeObject(forKey: Constants.HeldPostKey)
          self.putButton.isHidden = true
        }
      }, onError: { _ in
        self.showToast(text: "ネットワークに問題があるため、投稿を置けませんでした。", duration: Constants.TOAST_LENGTH_SHORT)
      })
    } catch {
      showToast(text: "投稿を置けませんでした", duration: Constants.TOAST_LENGTH_SHORT)
    }
  }

  func updatePosts() {
    api.getPosts(location: mapView.region.center, onComplete: { posts in
      // すでにある投稿をリセット
      DispatchQueue.main.async {
        self.pinPostDict.removeAll()
        NSLog("Removed all KVs")
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.notifiers.forEach({ item in
          UIApplication.shared.cancelLocalNotification(item)
        })
        var annotations = [MKAnnotation]()
        posts.forEach({ post in

          let annotation = MKPointAnnotation()
          annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(post.lat),
                                                             CLLocationDegrees(post.lon))
          annotations.append(annotation)
          self.pinPostDict[annotation.hash] = post
          NSLog("Added to Hash :" + self.pinPostDict.description)
          self.notifiers.append(self.createNotifier(post: post, radius: 30))
        })
        NSLog("Finally hash has " + String(self.pinPostDict.count) + " values")
        self.mapView.addAnnotations(annotations)
        self.notifiers.forEach({ item in
          //          NSLog("Notification regisitered, \(item.region?.description)")
          UIApplication.shared.scheduleLocalNotification(item)
        })
      }
    })
  }

  public func showToast(text: String, duration: Double) {
    toastLabel.text = text

    let fadeIn = CABasicAnimation(keyPath: "opacity")
    fadeIn.fromValue = 0
    fadeIn.toValue = 1
    fadeIn.isAdditive = false
    fadeIn.isRemovedOnCompletion = false
    fadeIn.duration = 0.25
    fadeIn.fillMode = kCAFillModeForwards

    let fadeOut = CABasicAnimation(keyPath: "opacity")
    fadeOut.fromValue = 1
    fadeOut.toValue = 0
    fadeOut.isRemovedOnCompletion = false
    fadeOut.duration = 0.75
    fadeOut.fillMode = kCAFillModeForwards
    fadeOut.beginTime = CACurrentMediaTime() + duration
    toastBox.layer.add(fadeOut, forKey: "fadeOut")
    toastBox.layer.add(fadeIn, forKey: "fadeIn")
  }

  // 参考: https://qiita.com/shindooo/items/edb6d4923fbf713a9777
  private func createNotifier(post: Post, radius: Float) -> UILocalNotification {
    let region: CLCircularRegion = CLCircularRegion(center: CLLocationCoordinate2DMake(CLLocationDegrees(post.lat),
                                                                                       CLLocationDegrees(post.lon)),
                                                    radius: CLLocationDistance(radius),
                                                    identifier: post.id.description)
    // 通知本体 (UILocalNotification)を作成
    let notification: UILocalNotification = UILocalNotification()
    notification.soundName = UILocalNotificationDefaultSoundName // 既定の通知音
    notification.alertBody = "この付近に投稿があります" // メッセージ
    notification.region = region // 領域
    notification.regionTriggersOnce = false // 一度のみか否か
    NSLog("\(notification.description)")
    notification.category = AppDelegate.nearPostsNotificationCat

    locationManager.startMonitoring(for: region)
    return notification
  }
}

extension MapViewController: MKMapViewDelegate {
  // ピンが落ちてきたときに呼ばれる
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      return nil
    }
    NSLog("Dictionary values: " + pinPostDict.description)
    let post: Post! = pinPostDict[annotation.hash]
    let pinView: MKPinAnnotationView!
    let accView = PostThreadView.createInstance()
    if post != nil {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: String(post.id))
      accView.parentVC = self
      accView.post = post //parentVCをセットする前に呼ぶと追記不能になる
      NSLog("Parent is set from MapVC")
      accView.addConstraint(NSLayoutConstraint(item: accView,
                                               attribute: .width,
                                               relatedBy: .equal,
                                               toItem: nil, attribute: .notAnAttribute,
                                               multiplier: 1, constant: 250))
      accView.addConstraint(NSLayoutConstraint(item: accView,
                                               attribute: .height,
                                               relatedBy: .equal,
                                               toItem: nil, attribute: .notAnAttribute,
                                               multiplier: 1, constant: 200))
    } else {
      NSLog("Here are the annotation hashes: " + pinPostDict.description)
      NSLog(String(annotation.hash) + " is not found")
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "")
    }
    pinView.animatesDrop = true
    pinView.canShowCallout = true
    pinView.detailCalloutAccessoryView = accView
    return pinView
  }

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    NSLog("View: \(String(describing: view.detailCalloutAccessoryView))")
    guard let postThView = view.detailCalloutAccessoryView as? PostThreadView else {
      return
    }
    postThView.prepareThread()
  }
}

extension MapViewController: UIGestureRecognizerDelegate {
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }
}

extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    switch status {
    case .authorizedAlways, .authorizedWhenInUse:
      break
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    default:
      break
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations[0].coordinate
//    NSLog("Location Updated. Lat: \(currentLocation?.latitude), Lon: \(currentLocation?.longitude)")
    if currentLocationButton.isSelected {
      mapView.setRegion(MKCoordinateRegionMake(currentLocation!, mapView.region.span), animated: true)
    }
  }
}
