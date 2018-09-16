//
//  TsukumoAPI.swift
//  tukumokkumokku
//
//  Created by kazu on 9/14/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import Foundation

struct Location {}

struct Post {
  var lat, lon: Float
  var text: String
}

// let->Constant(=const), var->Variable(=let)
// クロージャ: { hoge, _(要らないとき), fuga in [処理] }

class TsukumoAPI {
  static let serverUrl = URL(string: "https://tsukumokku.herokuapp.com")!
//  static let serverUrl = URL(string: "http://192.168.150.31:3000")!
  static let apiUrl = TsukumoAPI.serverUrl.appendingPathComponent("api/v1")

  static let defaultsKeyToken = "ApiKey"
  static let shared = TsukumoAPI()

  private var _key: String?
  var apiKey: String? {
    get {
      return _key
    }
    set {
      _key = newValue
      UserDefaults.standard.set(_key, forKey: TsukumoAPI.defaultsKeyToken)
    }
  }

  init() {
    apiKey = UserDefaults.standard.string(forKey: TsukumoAPI.defaultsKeyToken)
  }

  // めったに失敗はないだろうが、手動で値が書き換わった、垢を消されたなどのとき
  // falseが返ることがある
  func isAvailable(key: String, onComplete: @escaping (Bool) -> Void) {
    let url = URL(string: TsukumoAPI.apiUrl.description + "/accounts/available?token=\(key)")!

    let task = URLSession.shared.dataTask(with: url, completionHandler: { data, urlRes, _ in
      do {
        NSLog("url: \(urlRes?.url!.absoluteString)")
        NSLog("Data arrived. Data: \(String(data: data!, encoding: String.Encoding.utf8))")
        let obj: NSDictionary = try JSONSerialization.jsonObject(with: data!,
                                                                 options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
        NSLog("Obj: \(obj.description)")
        onComplete(obj.value(forKey: "result") as! Bool)
        NSLog("Called back, res: \(obj.value(forKey: "result") as! Bool)")
      } catch {
        NSLog("JSON Error")
      }
    })
    task.resume()
    NSLog("Test req. sent")
  }

  func getPosts(lat: Float, lon: Float, onComplete: @escaping ([Post]) -> Void) {
    let url = TsukumoAPI.apiUrl.appendingPathComponent("/posts")
    // resume()した時点で非同期になっている

    let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
      do {
        let json = try JSONSerialization.jsonObject(with: data!,
                                                    options: JSONSerialization.ReadingOptions.allowFragments)
        let list: NSArray = (json as! NSDictionary).value(forKey: "result") as! NSArray
        var posts = [Post]()
        list.forEach({ item in
          let post = item as! NSDictionary
          NSLog(post.description)
          posts.append(Post(lat: (post.value(forKey: "latitude") as! NSNumber).floatValue,
                            lon: (post.value(forKey: "longitude") as! NSNumber).floatValue,
                            text: post.value(forKey: "text") as! String))

        })
        onComplete(posts)
      } catch {
        NSLog("JSON Parse Error")
      }
    })
    task.resume()
    NSLog("Req sent.")
  }
}
