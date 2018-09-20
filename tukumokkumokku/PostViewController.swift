//
//  PostViewController.swift
//  tukumokkumokku
//
//  Created by kazu on 9/17/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import UIKit
import CoreLocation

class PostViewController: UIViewController, UITextViewDelegate {
  @IBOutlet var contentBox: UITextView!
  @IBOutlet var geoLabel: UILabel!
  @IBOutlet var headingLabel: UILabel!
  var currentLocation: CLLocationCoordinate2D?

  var api: TsukumoAPI!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    api = TsukumoAPI.shared
  }

  @IBAction func onCancelButtonClick(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func onSendButtonClick(_ sender: Any) {
    if currentLocation == nil { NSLog("Location is not set!") }
    do {
      NSLog("Location OK, calling sendPost()")
      try api.sendPost(location: currentLocation!,
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
}
