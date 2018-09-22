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
    updateLocations()
  }

  func updateLocations() {
    // 投稿を取得
    api.getPosts(location: currentLocation!, onComplete: { posts in
      var annotations = [MKAnnotation]()
      posts.forEach({ post in
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(post.lat), CLLocationDegrees(post.lon))
        if post.text.count > self.annotationTitleCount {
          annotation.title = post.text.prefix(self.annotationTitleCount).appending("…") // 7文字ぐらい？
        } else {
          annotation.title = post.text // 7文字ぐらい？
        }
        annotations.append(annotation)
      })
      DispatchQueue.main.async {
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(annotations)
      }
    })
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
    CommonUtil.checkLocationPermission(self, manager: manager, status: status)
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations[0].coordinate
    if !corrected {
      mapView.setRegion(MKCoordinateRegionMake(currentLocation!, zoomedSpan), animated: true)
      corrected = true
      updateLocations()
    }
  }
}
