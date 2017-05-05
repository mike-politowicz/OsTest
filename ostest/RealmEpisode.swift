//
//  RealmEpisode.swift
//  ostest
//
//  Created by Michael Politowicz on 5/4/17.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import RealmSwift

/**
 The episode Realm Object
 */
class Episode : Object {
  
  dynamic var uid : String = ""
  
  dynamic var title : String = ""
  
  dynamic var synopsis : String = ""
  
  dynamic var position : Int = 0
  
  dynamic var isFavourite : Bool = false
  
  var imageURLs = List<Image>()
  
  
  
  /**
   Creates a Realm Episode object from the APIEpisode
   */
  static func initEpisode (from api : APIEpisode) -> Episode {
    
    let images = List<Image>()
    for thisImageURL in api.imageURLs {
      let newImage = Image()
      newImage.url = thisImageURL
      images.append(newImage)
    }
    
    let episode = Episode()
    episode.uid = api.uid
    episode.title = api.title
    episode.synopsis = api.synopsis
    episode.position = api.position
    episode.imageURLs = images
    
    return episode
  }
  
  override static func primaryKey() -> String? {
    return "uid"
  }
  
}
