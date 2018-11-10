//
//  PostViewController.swift
//  tukumokkumokku
//
//  Created by kazu on 9/17/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import CoreLocation
import UIKit

class PostViewController: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
  @IBOutlet var contentBox: UITextView!
  @IBOutlet var geoLabel: UILabel!
  @IBOutlet var geoToolbar: UIToolbar!
  @IBOutlet var TapGestureRcg: UITapGestureRecognizer!

  var currentLocation: CLLocationCoordinate2D?

  var api: TsukumoAPI!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    api = TsukumoAPI.shared

    // バー全体に対し、タッチを有効化
    TapGestureRcg.addTarget(self, action: #selector(onToolbarTapped(_:)))
    geoToolbar.addGestureRecognizer(TapGestureRcg)
  }

  @objc func onToolbarTapped(_ sender: Any) {
    let slScene = storyboard!.instantiateViewController(withIdentifier: "selectLocationScene")
    present(slScene, animated: true, completion: nil)
  }

  @IBAction func onCancelButtonClick(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }

  @IBAction func onSendButtonClick(_ sender: Any) {
    if currentLocation == nil {
      NSLog("Location is not set!")
      return
    }
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
