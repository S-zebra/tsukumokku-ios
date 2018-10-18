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

  
  private static let NibName = "ShowPostView"
  static func createInstance() -> ShowPostView {
    NSLog("ShowPostView instantinated")
    return UINib(nibName: NibName, bundle: nil).instantiate(withOwner: nil, options: nil).first as! ShowPostView
  }

  /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
