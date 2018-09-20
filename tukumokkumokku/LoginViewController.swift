//
//  ViewController.swift
//  tukumokkumokku
//
//  Created by nakatake on 2018/09/13.
//  Copyright © 2018年 nakatake. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  let api = TsukumoAPI.shared
  override func viewDidLoad() {
    // Do any additional setup after loading the view, typically from a nib.
    super.viewDidLoad()
  }

  override func viewDidAppear(_ animated: Bool) {
    // 戻ってきたときに続行
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(LoginViewController.tryLogin),
                                           name: NSNotification.Name.UIApplicationDidBecomeActive,
                                           object: nil)
    // 最初の試行
    tryLogin()
  }

  @objc func tryLogin() {
    if AppDelegate.passedKey != nil && api.apiKey == nil { // Safariから戻ったとき
      api.isAvailable(key: AppDelegate.passedKey!, onComplete: { r in
        self.testCompleteCB(res: r)
      })
    } else if api.apiKey != nil { // ログイン済みのとき
      api.isAvailable(key: api.apiKey!, onComplete: { r in
        self.testCompleteCB(res: r)
      })
    } else { // 初回起動時
      CommonUtil.showAlert(title: "登録が必要です",
                             message: "このアプリをお使いいただくには、登録が必要です。登録を行ってください。")
    }
  }

  // ログイン結果が帰ってきたときの処理
  // res: true -> 地図画面へ
  // false -> ログイン要求Alertを出す
  func testCompleteCB(res: Bool) {
    NSLog("Test finished, res: \(res)")
    if res {
      if AppDelegate.passedKey != nil {
        api.apiKey = AppDelegate.passedKey!
      }
      NSLog("Moving to map...")
      DispatchQueue.main.async {
        self.moveToMap()
      }
    } else {
      api.apiKey = nil // 誤ったキーは削除
      CommonUtil.showAlert(title: "アカウント情報が誤っています", message: "アカウントが削除された等の理由で、ログインに失敗しました。ログインか新規登録をおこなってください。")
    }
  }

  // 地図画面に遷移する
  func moveToMap() {
    let mapScene = storyboard!.instantiateViewController(withIdentifier: "mapScene")
    present(mapScene, animated: true, completion: nil)
  }
}
