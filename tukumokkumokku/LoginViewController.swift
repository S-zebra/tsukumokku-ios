//
//  ViewController.swift
//  tukumokkumokku
//
//  Created by nakatake on 2018/09/13.
//  Copyright © 2018年 nakatake. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
  private let api = TsukumoAPI.shared
  @IBOutlet var waitMoreLabel: UILabel!

  override func viewDidLoad() {
    // Do any additional setup after loading the view, typically from a nib.
    super.viewDidLoad()
//    UserDefaults().removeObject(forKey: Constants.HeldPostKey)
  }

  override func viewDidAppear(_ animated: Bool) {
    // 戻ってきたときに続行
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(LoginViewController.tryLogin),
                                           name: NSNotification.Name.UIApplicationDidBecomeActive,
                                           object: nil)
    // 最初の試行
    tryLogin()
    if #available(iOS 10.0, *) {
      Timer(timeInterval: 3, repeats: false, block: { _ in
        self.waitMoreLabel.isHidden = false
      })
    } else {
      // Fallback on earlier versions
    }
  }

  @objc func tryLogin() {
    if api.apiKey == nil && AppDelegate.passedKey == nil { // 初回起動時
      NSLog("Key is nil")
      CommonUtil.showAlert(self, title: "登録が必要です",
                           message: "このアプリをお使いいただくには、登録が必要です。登録を行ってください。",
                           handler: redirectToLoginPage(_:))
      return
    }
    if AppDelegate.passedKey != nil { // Safariから戻ったとき
      testKey(key: AppDelegate.passedKey!)
    } else { // 2回目以降の起動時
      NSLog("key: \(String(describing: api.apiKey))")
      testKey(key: api.apiKey!)
    }
  }

  func redirectToLoginPage(_ action: UIAlertAction) {
    UIApplication.shared.openURL(TsukumoAPI.serverUrl)
  }

  func testKey(key: String!) {
    api.isAvailable(key: key, onComplete: { r in
      NSLog("isAvailable Result: \(r)")
      self.testCompleteCB(res: r)
    }, onError: { _ in
      DispatchQueue.main.async {
        CommonUtil.showAlert(self,
                             title: "通信に失敗しました",
                             message: "ネットワークがオフラインか、サーバーがダウンしている可能性があります。",
                             handler: nil)
        // TODO: ここどうしようか
      }
    })
  }

  // ログイン結果が帰ってきたときの処理
  // res: true -> 地図画面へ
  // false -> ログイン要求Alertを出す
  func testCompleteCB(res: Bool) {
    NSLog("Test finished, res: \(res)")
    if res { // ログイン成功
      if AppDelegate.passedKey != nil {
        api.apiKey = AppDelegate.passedKey! // APIクラス+UserDefaultsに保存
      }
      NSLog("Moving to map...")
      DispatchQueue.main.async {
        self.moveToMap()
      }
    } else {
      api.apiKey = nil // 誤ったキーは削除
      CommonUtil.showAlert(self,
                           title: "アカウント情報が誤っています",
                           message: "アカウントが削除された等の理由で、ログインに失敗しました。ログインか新規登録をおこなってください。",
                           handler: redirectToLoginPage(_:))
    }
  }

  // 地図画面に遷移する
  func moveToMap() {
    let mapScene = storyboard!.instantiateViewController(withIdentifier: "mapScene")
    present(mapScene, animated: true, completion: nil)
  }
}
