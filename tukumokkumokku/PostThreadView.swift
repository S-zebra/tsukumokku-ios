//
//  PostThreadView.swift
//  tukumokkumokku
//
//  Created by kazu on 11/25/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import UIKit

class PostThreadView: UIView {
  static let NibName = "PostThreadView"
  @IBOutlet var collectionView: UICollectionView!

  private var _replies = [Post]()
//  var replies: [Post]! {
//    get {
//      return _replies
//    }
//    set {
//      _replies = newValue
//    }
//  }

  var parentVC: MapViewController!
  private var postView: PostViewCell!
  private var _post: Post!
  var post: Post! {
    get {
      return _post
    }
    set {
      _post = newValue
      postView = PostViewCell.createInstance()
      postView.post = _post
      NSLog("Parent is set " + String(describing: parentVC))
      postView.parent = parentVC
    }
  }

  static func createInstance() -> PostThreadView {
    NSLog("PostThreadView instantiated")
    return UINib(nibName: NibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as! PostThreadView
  }

  func prepareThread() {
    if post.parentId > 0 {
      NSLog("This post has a parent")
//      parentVC.api.getPost(id: post.parentId, onComplete: fetchParent)
    } else {
      NSLog("This is root post")
    }
    showReplies()
  }

  private func fetchParent(post: Post?) {
    _replies.append(post!) //末尾に追加
    if _replies.last!.parentId > 0 {
      NSLog("This post has more parent")
      parentVC.api.getPost(id: _replies.last!.parentId, onComplete: fetchParent, onError: { _ in return})
    } else {
      NSLog("This is root post")
      _replies = _replies.reversed() //ひっくり返す
    }
  }

  private func showReplies() {
    _replies.forEach({ p in
      let repView = ReplyPostCell.createInstance()
      repView.post = p
      //          repView.frame = CGRect(x: 0, y: 125 * self.collectionView.subviews.count, width: 250, height: 125)
      //          if self.collectionView.subviews.last != nil {
      //            repView.addConstraint(NSLayoutConstraint(item: repView, attribute: .top,
      //                                                     relatedBy: .equal,
      //                                                     toItem: self.collectionView.subviews.last!, attribute: .bottom,
      //                                                     multiplier: 1, constant: 8))
      //          } else {
      //            repView.addConstraint(NSLayoutConstraint(item: repView, attribute: .top,
      //                                                     relatedBy: .equal,
      //                                                     toItem: nil, attribute: .notAnAttribute,
      //                                                     multiplier: 1, constant: 0))
      //          }
      collectionView.addSubview(repView)
    })
    collectionView.addSubview(postView) //Rootを追加
  }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
