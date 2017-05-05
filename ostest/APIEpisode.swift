//
//  APIEpisode.swift
//  ostest
//
//  Created by Michael Politowicz on 5/4/17.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftyBeaver

/**
 API Episode object
 */
struct APIEpisode {
  
  /// The UID
  let uid : String
  
  /// The title of the episode
  let title : String
  
  /// Episode synopsis
  let synopsis : String
  
  /// Episode position
  let position : Int
  
  /// Image URLs
  let imageURLs : [String]
  
  /// Content URL
  let contentURL : String
  
  /**
   A basic initialisers for the API Episode object
   
   - parameter uid: The Uid of this episode
   - parameter contentURL: The URL String where the episode details can be found
   - parameter position: The position where the episode should be displayed relative to other episodes
   - parameter title: The title of the episode
   - parameter synopsis: A synopsis of this episode
   - parameter imageURLs: An array of image URL Strings for this episode
   */
  init (uid : String, contentURL : String, position : Int, title : String = "", synopsis : String = "", imageURLs : [String] = [String]() ) {
    self.uid = uid
    self.contentURL = contentURL
    self.position = position
    self.title = title
    self.synopsis = synopsis
    self.imageURLs = imageURLs
  }
  
  
  /**
   Initialises from a JSON object and returns an array of [APIEpisode]
   
   - parameter json: The JSON object to parse
   - returns: [APIEpisode] if the JSON was valid
   */
  static func parse (_ json : JSON) -> [APIEpisode]? {
    
    /// Check there is an array of objects
    guard let objects = json["objects"].array else {
      return nil
    }
    
    /// Episodes array
    var apiEpisodes : [APIEpisode] = [APIEpisode]()
    
    /// For each object
    for thisEpisode in objects {
      
      /// Check that object is an episode
      guard thisEpisode["content_type"] == "episode" else {
        continue
      }
      
      guard let uid = thisEpisode["uid"].string else {
        continue
      }
      
      guard let contentURL = thisEpisode["content_url"].string else {
        continue
      }
      
      guard let position = thisEpisode["position"].int else {
        continue
      }
      
      /// Object
      let episode = APIEpisode(uid: uid,
                               contentURL: contentURL,
                               position: position)
      
      /// Append to array
      apiEpisodes.append(episode)
      
    }
    
    /// Return if more than 0
    if apiEpisodes.count > 0 {
      return apiEpisodes
    }
    
    /// Nil return
    return nil
    
  }
  
}

