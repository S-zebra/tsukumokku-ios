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
  let annotationTitleCount = 7
  let api = TsukumoAPI.shared

  var corrected = false

  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    mapView.delegate = self
    // Do any additional setup after loading the view.
  }

  override func viewDidAppear(_ animated: Bool) {
    locationManager.startUpdatingLocation()
    let newRegion = MKCoordinateRegionMake(mapView.region.center, zoomedSpan)
    mapView.setRegion(newRegion, animated: true)
  }

  @IBAction func refreshButtonTappeed(_ sender: Any) {
    corrected = false
    updatePosts()
  }

  func updatePosts() {
    // 投稿を取得
    api.getPosts(location: currentLocation!, onComplete: { posts in
      var annotations = [MKAnnotation]()
      var notifiers = [UILocalNotification]()
      posts.forEach({ post in
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(post.lat), CLLocationDegrees(post.lon))
        if post.text.count > self.annotationTitleCount {
          annotation.title = post.text.prefix(self.annotationTitleCount).appending("…") // 7文字ぐらい？
        } else {
          annotation.title = post.text // 7文字ぐらい？
        }
        annotations.append(annotation)
        notifiers.append(self.createNotifier(post: post, radius: 30))
      })
      DispatchQueue.main.async {
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(annotations)
        notifiers.forEach({ item in
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
    notification.category = AppDelegate.nearPostsNotificationCat
    return notification
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension MapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "")
    pinView.canShowCallout = true
    pinView.animatesDrop = true
    return pinView
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
    NSLog("Location Updated. Lat: \(currentLocation?.latitude), Lon: \(currentLocation?.longitude )")
    if !corrected {
      mapView.setRegion(MKCoordinateRegionMake(currentLocation!, zoomedSpan), animated: true)
      corrected = true
      updatePosts()
    }
  }
}
