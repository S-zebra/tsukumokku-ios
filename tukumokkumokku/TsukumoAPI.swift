//
//  TsukumoAPI.swift
//  tukumokkumokku
//
//  Created by kazu on 9/14/18.
//  Copyright © 2018 nakatake. All rights reserved.
//

import CoreLocation
import Foundation

struct Post: Codable {
  var lat, lon: Float
  var text: String
}

enum HTTPStatusCode: Int {
  case OK = 200
  case BadRequest = 400
  case Forbidden = 403
  case NotFound = 404
  case InternalError = 500
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

  // ログイン可否の確認 (onCompleteに返される)
  // 手動で値が書き換わった、垢を消されたなどのときはfalseが返ることがある
  func isAvailable(key: String, onComplete: @escaping (Bool) -> Void) {
    let url = URL(string: TsukumoAPI.apiUrl.description + "/accounts/available?token=\(key)")!
    let task = URLSession.shared.dataTask(with: url, completionHandler: { data, urlRes, _ in
      do {
        NSLog("url: \(String(describing: urlRes?.url!.absoluteString))")
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

  // 投稿を取得
  func getPosts(location: CLLocationCoordinate2D, onComplete: @escaping ([Post]) -> Void) {
    let url = URL(string: TsukumoAPI.apiUrl.description + "/posts?lat=\(Float(location.latitude))&lon=\(Float(location.longitude))")!
    // resume()した時点で非同期になっている

    let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
      do {
        let json = try JSONSerialization.jsonObject(with: data!,
                                                    options: JSONSerialization.ReadingOptions.allowFragments)
        onComplete(self.jsonToPosts(json: json, arrayKey: "result"))
      } catch {
        NSLog("JSON Parse Error")
      }
    })
    task.resume()
    NSLog("Req sent.")
  }

  // 投稿を送信
  func sendPost(location: CLLocationCoordinate2D, text: String, onComplete: @escaping () -> Void) throws {
    var req = URLRequest(url: TsukumoAPI.apiUrl.appendingPathComponent("/posts"))
    req.httpMethod = "POST"
    req.setValue("application/json", forHTTPHeaderField: "Content-Type")
    req.setValue(apiKey!, forHTTPHeaderField: "API_TOKEN")
    let post = Post(lat: Float(location.latitude), lon: Float(location.longitude), text: text)
    let encoder = JSONEncoder()
    let data = try encoder.encode(post)
    let task = URLSession.shared.uploadTask(with: req, from: data, completionHandler: { _, _, _ in
      onComplete()
    })
    task.resume()
    NSLog("Post sent")
  }

  private func jsonToPosts(json: Any, arrayKey: String) -> [Post] {
    let list: NSArray = (json as! NSDictionary).value(forKey: "result") as! NSArray
    var posts = [Post]()
    list.forEach({ item in
      let post = item as! NSDictionary
      NSLog(post.description)
      posts.append(Post(lat: (post.value(forKey: "latitude") as! NSNumber).floatValue,
                        lon: (post.value(forKey: "longitude") as! NSNumber).floatValue,
                        text: post.value(forKey: "text") as! String))

    })
    return posts
  }
}
