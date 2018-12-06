//
//  PostViewCell.swift
//  tukumokkumokku
//
//  Created by kazu on 11/25/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import UIKit

class PostViewCell: UICollectionViewCell {
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  private static let NibName = "PostViewCell"
  @IBOutlet var BodyTextBox: UILabel!
  var parent: MapViewController!

  let api = TsukumoAPI.shared

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

  //  private var _parentPosts: [Post]!
  //  var parentPosts: [Post] {
  //    get {
  //      return _parentPosts
  //    }
  //    set {
  //      _parentPosts = newValue
  //    }
  //  }

  static func createInstance() -> PostViewCell {
    NSLog("PostViewCell instantinated")
    return UINib(nibName: NibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as! PostViewCell
  }

  @IBAction func ReplyButtonTapped(_ sender: Any) {
    NSLog("Parent:" + String(describing: parent))
    let newPostView: PostViewController = parent.storyboard!.instantiateViewController(withIdentifier: "newPostScene") as! PostViewController
    parent.present(newPostView, animated: true)
//    newPostView.replyParent = _post
  }

  @IBAction func HoldButtonTapped(_ sender: Any) {
    // IDが一致していれば、全く同じ投稿であるということは確定的に明らか
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
}
