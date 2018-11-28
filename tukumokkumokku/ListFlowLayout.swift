//
//  ListFlowLayout.swift
//  tukumokkumokku
//
//  Created by kazu on 11/25/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import Foundation
import UIKit
class ListFlowLayout: UICollectionViewFlowLayout {
  var height: CGFloat = 150
  override var itemSize: CGSize {
    get {
      return CGSize(width: itemWidth(), height: height)
    }
    set {
      self.itemSize = CGSize(width: itemWidth(), height: height)
    }
  }

  override init() {
    super.init()
    setupLayout()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupLayout()
  }

  func setupLayout() {
    minimumInteritemSpacing = 0
    minimumLineSpacing = 1
    scrollDirection = .vertical
  }

  func itemWidth() -> CGFloat {
    return collectionView!.frame.width
  }

  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
    return collectionView!.contentOffset
  }
}
