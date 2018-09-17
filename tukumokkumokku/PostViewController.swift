//
//  PostViewController.swift
//  tukumokkumokku
//
//  Created by kazu on 9/17/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import UIKit

class PostViewController: UIViewController, UITextViewDelegate {
  @IBOutlet var contentBox: UITextView!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    let toolBar = UIToolbar()
    let geoButton: UIBarButtonItem = UIBarButtonItem(title: "Location",
                                                     style: .plain,
                                                     target: self,
                                                     action: #selector(geoButtonAction(_:)))
    toolBar.setItems([geoButton], animated: true)
    toolBar.sizeToFit()
    contentBox.delegate = self
    contentBox.inputAccessoryView = toolBar
  }

  override func viewDidAppear(_ animated: Bool) {}

  @objc func geoButtonAction(_ sender: UIButton) {
    NSLog("geoButton tapped")
  }

  @IBAction func onSendButtonClick(_ sender: Any) {}

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
}
