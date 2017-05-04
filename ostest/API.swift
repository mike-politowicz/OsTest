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
  let log = SwiftyBeaver.self
  
  /// The base URL
  let baseURL = "http://feature-code-test.skylark-cms.qa.aws.ostmodern.co.uk:8000"
  
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
   Updates an APISet object from the /sets/ endpoint to a full formed APISet with correct images
   
   - parameter set: The APISet to convert
   - returns: APISet
   */
  func updateSet (set : APISet, completion : @escaping (_ isSuccess : Bool, _ set : APISet?) -> Void) {
    
    guard let apiString = set.imageURLs.first else {
      return
    }
    log.verbose("Getting image information with URL \(apiString)")
    
    
    /// Request
    Alamofire.request("\(self.baseURL)\(apiString)").validate().responseJSON { response in
      
      self.log.verbose("Response for getting set image \(response.response.debugDescription)")
      
      switch response.result {
      case .success(let data):
        guard let url = JSON(data)["url"].string else {
          completion(false, nil)
          return
        }
        let newSet = APISet(uid: set.uid, title: set.title, setDescription: set.setDescription, setDescriptionFormatted: set.setDescriptionFormatted, summary: set.summary, imageURLs: [url])
        completion(true, newSet)
      case .failure(let error):
        self.log.error("Invalid response status updating sets: \(error.localizedDescription)")
        completion(false, nil)
      }
    }
  }
}
