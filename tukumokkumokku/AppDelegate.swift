//
//  AppDelegate.swift
//  tukumokkumokku
//
//  Created by nakatake on 2018/09/13.
//  Copyright © 2018年 nakatake. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  static var passedKey: String?
  static let nearPostsNotificationCat: String = "POSTS_ARE_NEAR_HERE"

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    self.window?.tintColor = UIColor.tsukumoYellow()
    application.registerUserNotificationSettings(createNotificationOptions())
    return true
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
    if url.scheme == "tmokku" && (url.query?.contains("token="))! {
      // tmokku://login/callback?hage=piyo&token=XXXX&hoge=fuga
      // query?.split("token=")[1].split("&")[0]
      let queries = url.query?.components(separatedBy: "token=")[1]
      AppDelegate.passedKey = (queries?.contains("&"))! ? queries?.components(separatedBy: "&")[1] : queries
    }
    return true
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}

extension UIColor {
  static func tsukumoYellow() -> UIColor {
    return UIColor(red: 0.7, green: 0.61, blue: 0, alpha: 1)
  }
}

extension AppDelegate {
  private func createNotificationOptions() -> UIUserNotificationSettings {
    let openAction = UIMutableUserNotificationAction()
    openAction.title = "見る"
    openAction.identifier = "OPEN"
    openAction.activationMode = .foreground
    openAction.isDestructive = false
    openAction.isAuthenticationRequired = true

    let dismissAction = UIMutableUserNotificationAction()
    dismissAction.title = "閉じる"
    dismissAction.identifier = "DISMISS"
    dismissAction.activationMode = .background
    dismissAction.isDestructive = false
    dismissAction.isAuthenticationRequired = false

    let interactiveCategory = UIMutableUserNotificationCategory()
    interactiveCategory.identifier = AppDelegate.nearPostsNotificationCat
    interactiveCategory.setActions([openAction, dismissAction], for: .minimal)

    let categories = NSSet(object: interactiveCategory) as! Set<UIUserNotificationCategory>
    return UIUserNotificationSettings(types: .alert, categories: categories)
  }
}
