//
//  ShowPostView.swift
//  tukumokkumokku
//
//  Created by kazu on 10/18/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import UIKit

class ShowPostView: UIView {
  @IBOutlet var BodyTextBox: UITextView!

  private var _post: Post!
  var post: Post {
    get {
      return _post
    }
    set {
      _post = newValue
      BodyTextBox.text = _post.text
    }
  }

  private static let NibName = "ShowPostView"
  var parent: MapViewController!

  static func createInstance() -> ShowPostView {
    NSLog("ShowPostView instantinated")
    return UINib(nibName: NibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as! ShowPostView
  }

  @IBAction func ReplyButtonTapped(_ sender: Any) {}

  @IBAction func HoldButtonTapped(_ sender: Any) {
    //IDが一致していれば、全く同じ投稿であるということは確定的に明らか
    if TsukumoAPI.getStoredPost() != nil {
      parent.showToast(text: "すでに持っている投稿を置く必要があります", duration: Constants.TOAST_LENGTH_SHORT)
      return
    }
    do {
      NSLog(_post.debugDescription)
      try TsukumoAPI.storePost(post: _post)
      parent.showToast(text: "投稿を持ちました", duration: Constants.TOAST_LENGTH_SHORT)
      parent.setPutButtonVisibility(visible: true)
    } catch let message {
      NSLog("Containing JSON Error!" + message.localizedDescription)
    }
  }

  /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
