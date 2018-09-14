//
//  ViewController.swift
//  tukumokkumokku
//
//  Created by nakatake on 2018/09/13.
//  Copyright © 2018年 nakatake. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet var link: UIButton!
  static let KEY_API_TOKEN="ApiKey"
  override func viewDidLoad() {
    super.viewDidLoad()
    let ud = UserDefaults() //UserDefaults isn't secure. Consider using Keychain.
    if (ud.string(forKey: Constants.KEY_API_TOKEN) != nil) {

    }
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func linktap(_ sender: Any) {
    let url = URL(string: "https://tsukumokku.herokuapp.com")!
    UIApplication.shared.open(url)
  }
}
