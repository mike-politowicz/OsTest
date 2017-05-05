//
//  API.swift
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
 The API Class connects to the Skylark API to access content and present it type safe structs
 */
class API {
  
  /// Singleton instance
  static let instance = API()
  
  /// Log
  fileprivate let log = SwiftyBeaver.self
  
  /// The base URL
  fileprivate let baseURL = "http://feature-code-test.skylark-cms.qa.aws.ostmodern.co.uk:8000"
  
  /**
   Get sets
   */
  func getSets (completion : @escaping (_ isSuccess : Bool, _ set : [APISet]?) -> Void) {
    
    let apiString = "\(baseURL)/api/sets/"
    log.verbose("Getting sets with URL \(apiString)")
    
    /// Request
    Alamofire.request(apiString).validate().responseJSON { response in
      
      self.log.verbose("Response for getting sets \(response.response.debugDescription)")
      
      switch response.result {
      case .success(let data):
        completion(true, APISet.parse(JSON(data)))
      case .failure(let error):
        self.log.error("Invalid response status getting sets: \(error.localizedDescription)")
        completion(false, nil)
      }

    }
    
  }
  
  /**
   Updates APIEpisode objects from the /sets/ endpoint
   
   - parameter set: The APISet to get content from
   - returns: [APIEpisode]?
   */
  func getEpisodes (setUID : String, completion : @escaping (_ isSuccess : Bool, _ set : [APIEpisode]?) -> Void) {
    
    let apiString = "\(baseURL)/api/sets/\(setUID)/items/"

    log.verbose("Getting image information with URL \(apiString)")
    
    /// Request
    Alamofire.request(apiString).validate().responseJSON { response in
      
      self.log.verbose("Response for getting sets \(response.response.debugDescription)")
      
      switch response.result {
      case .success(let data):
        guard let apiEpisodes = APIEpisode.parse(JSON(data)) else {
          completion(true, nil)
          return
        }
        self.updateEpisodes(episodes: apiEpisodes) { (isSuccess, updatedEpisodes) in
          completion(true, updatedEpisodes)
        }
      case .failure(let error):
        self.log.error("Invalid response status getting set content: \(error.localizedDescription)")
        completion(false, nil)
      }
    }
  }
  
  
  fileprivate func updateEpisodes (episodes : [APIEpisode], completion : @escaping (_ isSuccess : Bool, _ episodes : [APIEpisode]) -> Void) {
    var updatedEpisodes = [APIEpisode]()
    for episode in episodes {
      self.updateEpisode(episode: episode) { (isSuccess, updatedEpisode) in
        updatedEpisodes.append(updatedEpisode ?? episode)
        if updatedEpisodes.count == episodes.count {
          completion(true, updatedEpisodes)
        }
      }
    }
  }
  
  /**
   Updates an APISet object from the /sets/ endpoint to a full formed APISet with correct images
   
   - parameter set: The APISet to convert
   - returns: APISet
   */
  fileprivate func updateEpisode (episode : APIEpisode, completion : @escaping (_ isSuccess : Bool, _ set : APIEpisode?) -> Void) {
    
    /// Guard episode content URL
    guard episode.contentURL != "" else {
      log.warning("No content URL for episode UID: '\(episode.uid)'")
      completion(false, nil)
      return
    }
    let apiContentString = self.baseURL + episode.contentURL
    log.verbose("Getting episode information with URL \(apiContentString)")
    
    /// Request - episode content
    Alamofire.request(apiContentString).validate().responseJSON { response in
      self.log.verbose("Response for getting episode content \(response.response.debugDescription)")
      
      switch response.result {
        
      /// Successful request - episode content
      case .success(let data):
        guard let title = JSON(data)["title"].string, let synopsis = JSON(data)["synopsis"].string, let jsonImageURLs = JSON(data)["image_urls"].array else {
          self.log.error("Invalid episode content data")
          completion(true, nil)
          return
        }
        var imageURLs = [String]()
        for thisImageURL in jsonImageURLs {
          if let url = thisImageURL.string {
            imageURLs.append(url)
          }
        }
        var newEpisode = APIEpisode.init(uid: episode.uid,
                                         contentURL: episode.contentURL,
                                         position: episode.position,
                                         title: title,
                                         synopsis: synopsis,
                                         imageURLs: imageURLs) //["/api/images/imag_fcdf67481d8147e6844d838f4112fcaa/", "/api/images/imag_fcdf67481d8147e6844d838f4112fcab/"])
        
        // Get episode image URL
        guard let apiImageURL = newEpisode.imageURLs.first else {
          completion(true, newEpisode)
          return
        }
        let apiImageString = self.baseURL + apiImageURL
        self.log.verbose("Getting image information with URL \(apiImageString)")
        
        /// Request - image URL
        Alamofire.request(apiImageString).validate().responseJSON { response in
          self.log.verbose("Response for getting set image \(response.response.debugDescription)")
          
          switch response.result {
            
          /// Successful request - image URL
          case .success(let data):
            guard let url = JSON(data)["url"].string else {
              completion(true, newEpisode)
              return
            }
            newEpisode = APIEpisode.init(uid: episode.uid,
                                         contentURL: episode.contentURL,
                                         position: episode.position,
                                         title: title,
                                         synopsis: synopsis,
                                         imageURLs: [url])
            completion(true, newEpisode)
            
          /// Failed request - image URL
          case .failure(let error):
            self.log.error("Invalid response status updating episodes: \(error.localizedDescription)")
            completion(false, newEpisode)
          }
        }
        
        /// Failed request - episode content
        case .failure(let error):
        self.log.error("Invalid response status updating episodes: \(error.localizedDescription)")
        completion(false, nil)
      }
    }
  }
}
