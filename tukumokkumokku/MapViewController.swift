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
  @IBOutlet var ToastNotification: UIVisualEffectView!
  @IBOutlet var NotificationLabel: UILabel!

  var locationManager: CLLocationManager!
  var currentLocation: CLLocationCoordinate2D?
  var notifiers = [UILocalNotification]()
  let api = TsukumoAPI.shared

  var pinPostDict: Dictionary<Int, Post>!

  override func viewDidLoad() {
    super.viewDidLoad()
    pinPostDict = Dictionary()
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    mapView.delegate = self
    mapView.showsUserLocation = true
    panGestureRcg.delegate = self
    panGestureRcg.addTarget(self, action: #selector(onMapPanned(_:)))
    // Do any additional setup after loading the view.
  }

  override func viewDidAppear(_ animated: Bool) {
    locationManager.startUpdatingLocation()
    let newRegion = MKCoordinateRegionMake(mapView.region.center,
                                           MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005))
    mapView.setRegion(newRegion, animated: false)
    updatePosts()
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

  func updatePosts() {
    // 投稿を取得
    api.getPosts(location: mapView.region.center, onComplete: { posts in

      // すでにある投稿をリセット
      DispatchQueue.main.async {
        self.pinPostDict.removeAll()
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.notifiers.forEach({ item in
          UIApplication.shared.cancelLocalNotification(item)
        })
      }

      var annotations = [MKAnnotation]()
      posts.forEach({ post in
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(post.lat),
                                                           CLLocationDegrees(post.lon))
        annotations.append(annotation)
        self.pinPostDict[annotation.hash] = post
        NSLog("Added " + self.pinPostDict.description)
        self.notifiers.append(self.createNotifier(post: post, radius: 30))
      })
      NSLog("Final hash value: " + String(self.pinPostDict.count))

      DispatchQueue.main.async {
        self.mapView.addAnnotations(annotations)
        self.notifiers.forEach({ item in
          NSLog("Notification regisitered, \(item.region?.description)")
          UIApplication.shared.scheduleLocalNotification(item)
        })
      }
    })

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
    let post: Post! = pinPostDict[annotation.hash]
    let pinView: MKPinAnnotationView!
    let accView = ShowPostView.createInstance()
    if post != nil {
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: String(post.id))
      accView.BodyTextBox.text = post.text
    } else {
      NSLog("Here are the annotation hashes: " + pinPostDict.description)
      NSLog(String(annotation.hash) + " does not found")
      pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "")
    }
    pinView.animatesDrop = true
    pinView.canShowCallout = true
    pinView.detailCalloutAccessoryView = accView
    return pinView
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
    NSLog("Location Updated. Lat: \(currentLocation?.latitude), Lon: \(currentLocation?.longitude)")
    if currentLocationButton.isSelected {
      mapView.setRegion(MKCoordinateRegionMake(currentLocation!, mapView.region.span), animated: true)
    }
  }
}
