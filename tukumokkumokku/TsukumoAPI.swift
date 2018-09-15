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
  static let serverUrl = URL(string: "https://tsukumokku.herokuapp.com/api/v1")!
  static let defaultsKeyToken = "ApiKey"
  static let shared = TsukumoAPI()
  private init() {}

  func getPosts(lat: Float, lon: Float, onComplete: @escaping ([Post]) -> Void) throws {
    let url = TsukumoAPI.serverUrl.appendingPathComponent("/posts")
    var apiKey: String? = nil
    // resume()した時点で非同期になっている

    let task = URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
      do {
        let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments)
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
