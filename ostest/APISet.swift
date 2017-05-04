//
//  APISets.swift
//  ostest
//
//  Created by Maninder Soor on 28/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import SwiftyBeaver

/**
 API Sets object
 */
struct APISet {
  
  /// The UID
  let uid : String!
  
  /// The title of the set
  let title : String!
  
  /// Set description
  let setDescription : String!
  
  /// Set description formatted
  let setDescriptionFormatted : String!
  
  /// Set summary
  let summary : String!
  
  /// Image URLs
  let imageURLs : [String]!
  
  /**
   A basic initialisers for the API Set object
   
   - parameter uid: The Uid of this set
   - parameter title: The title of the set
   - parameter setDescription: The description of the set
   - parameter setDescriptionFormatted: The formatter (usually HTML) description of the set
   - parameter summary: A summary of this set
   - parameter imageURLs: An array of image URL Strings for this set
   */
  init (uid : String, title : String, setDescription : String, setDescriptionFormatted : String, summary : String, imageURLs : [String] ) {
    self.uid = uid
    self.title = title
    self.setDescription = setDescription
    self.setDescriptionFormatted = setDescriptionFormatted
    self.summary = summary
    self.imageURLs = imageURLs
    
  }
  
  
  /**
   Initialises from a JSON object and returns an array of [APISets]
   
   - parameter json: The JSON object to parse
   - returns: [APISets] if the JSON was valid
   */
  static func parse (_ json : JSON) -> [APISet]? {
    
    /// Check there is an array of objects
    guard let objects = json["objects"].array else {
      return nil
    }
    
    /// Sets array
    var apiSets : [APISet] = [APISet]()
    
    /// For each object
    for thisSet in objects {
      
      guard let uid = thisSet["uid"].string else {
        continue
      }
      
      guard let title = thisSet["title"].string else {
        continue
      }
      
      guard let setDescription = thisSet["body"].string else {
        continue
      }
      
      guard let setDescriptionFormatted = thisSet["formatted_body"].string else {
        continue
      }
      
      guard let summary = thisSet["summary"].string else {
        continue
      }
      
      guard let imageURLs = thisSet["image_urls"].array else {
        continue
      }
      
      var urls = [String]()
      for thisImageURL in imageURLs {
        if let url = thisImageURL.string {
          urls.append(url)
        }
      }
      
      /// Object
      let set = APISet(uid: uid,
                       title: title,
                       setDescription: setDescription,
                       setDescriptionFormatted: setDescriptionFormatted,
                       summary: summary,
                       imageURLs: urls)
      
      /// Append to array
      apiSets.append(set)
      
    }
    
    /// Return if more than 0
    if apiSets.count > 0 {
      return apiSets
    }
    
    /// Nil return
    return nil
    
  }
  
}
