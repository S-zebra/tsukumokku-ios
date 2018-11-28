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

  private var api: TsukumoAPI!

  @IBOutlet var ReplyToBar: UIToolbar!
  @IBOutlet var ReplyToLabel: UILabel!

  private var _replyParent: Post?
  var replyParent: Post? {
    get {
      return _replyParent
    }
    set {
      _replyParent = newValue
      if newValue != nil {
        ReplyToBar.isHidden = false
        ReplyToLabel.text = newValue!.text
      } else {
        ReplyToBar.isHidden = true
      }
    }
  }

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

  @IBAction func replyCancelButtonTapped(_ sender: Any) {
    replyParent = nil
  }

  @IBAction func onSendButtonClick(_ sender: Any) {
    if currentLocation == nil {
      NSLog("Location is not set!")
      return
    }
    do {
      NSLog("Location OK, calling sendPost()")
      let post = Post(id: 0,
                      parentId: replyParent?.id ?? -1,
                      lat: Float(currentLocation!.latitude),
                      lon: Float(currentLocation!.longitude), text: contentBox.text)
      try api.sendPost(post: post,
                       onComplete: {
                         NSLog("Post Complete!")
                         DispatchQueue.main.async {
                           self.dismiss(animated: true, completion: nil)
                         }

                       }, onError: { _ in
                         DispatchQueue.main.async {
                           CommonUtil.showAlert(self, title: "投稿の送信に失敗しました",
                                                message: "インターネット接続がない可能性があります。", handler: nil)
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
