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
  var annotations: [MKPointAnnotation] = [MKPointAnnotation]()
  let api = TsukumoAPI.shared
  var timer: Timer!

  var corrected = false
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager = CLLocationManager()
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    // Do any additional setup after loading the view.
  }

  override func viewDidAppear(_ animated: Bool) {
    locationManager.startUpdatingLocation()
    let newRegion = MKCoordinateRegionMake(mapView.region.center, zoomedSpan)
    mapView.setRegion(newRegion, animated: true)
    Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: { _ in
      self.updateLocations()
    })
  }

  func updateLocations() {
    // 投稿を取得
    api.getPosts(location: currentLocation!, onComplete: { posts in
      posts.forEach({ post in
        let locationOfPost = CLLocationCoordinate2DMake(CLLocationDegrees(post.lat), CLLocationDegrees(post.lon))

        // 同一のものは飛ばす
        self.annotations.forEach({ a in
          if a.coordinate.latitude == locationOfPost.latitude
            && a.coordinate.longitude == locationOfPost.longitude
            && a.title == post.text.prefix(7).appending("…") {
            return
          }
        })

        let annotation = MKPointAnnotation()
        annotation.coordinate = locationOfPost
        annotation.title = post.text.prefix(7).appending("…") // 7文字ぐらい？
        self.annotations.append(annotation)
        DispatchQueue.main.async {
          self.mapView.addAnnotations(self.annotations)
        }
      })
    })
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}

extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    CommonUtil.checkLocationPermission(self, manager: manager, status: status)
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations[0].coordinate
    if !corrected {
      mapView.setRegion(MKCoordinateRegionMake(currentLocation!, zoomedSpan), animated: true)
      corrected = true
    }
  }
}
