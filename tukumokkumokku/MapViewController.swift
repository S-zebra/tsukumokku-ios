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


  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    currentLocation = locations[0].coordinate
    mapView.setCenter(currentLocation!, animated: true)
//    // 投稿を取得
//    api.getPosts(location: currentLocation!, onComplete: { posts in
//      posts.forEach({ post in
//        let locationOfPost = CLLocationCoordinate2DMake(CLLocationDegrees(post.lat), CLLocationDegrees(post.lon))
//
//        //同一のものは飛ばす
//        self.annotations.forEach({ a in
//          if a.coordinate.latitude == locationOfPost.latitude
//            && a.coordinate.longitude == locationOfPost.longitude {
//            return
//          }
//        })
//
//        let annotation = MKPointAnnotation()
//        annotation.coordinate = locationOfPost
//        annotation.title = post.text.prefix(7).appending("…") // 7文字ぐらい？
//        self.annotations.append(annotation)
//        DispatchQueue.main.async {
//          self.mapView.addAnnotations(self.annotations)
//        }
//      })
//    })

  }

  func showAlert(title: String, message: String) {
    let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
    controller.addAction(action)
    present(controller, animated: true)
  }
}
