//
//  ReplyPostCell.swift
//  tukumokkumokku
//
//  Created by kazu on 11/25/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import UIKit

class ReplyPostCell: UICollectionViewCell {
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  @IBOutlet var bodyTextLabel: UILabel!
  @IBOutlet var geoLabel: UILabel!

  private var _post: Post!
  var post: Post {
    get {
      return _post
    }
    set {
      _post = newValue
      bodyTextLabel.text = _post.text
      geoLabel.text = "@" + String(_post.lat) + ", " + String(_post.lon)
    }
  }

  private static let NibName = "ReplyPostCell"
  static func createInstance() -> ReplyPostCell {
    NSLog(NibName + " instantiated")
    return UINib(nibName: NibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as! ReplyPostCell
  }
}
