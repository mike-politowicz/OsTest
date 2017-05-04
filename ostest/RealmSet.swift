//
//  RealmSet.swift
//  ostest
//
//  Created by Maninder Soor on 28/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import RealmSwift


/**
 The set Realm Object
 */
class Movie : Object {
  
  dynamic var uid : String = ""
  
  dynamic var title : String = ""
  
  dynamic var setDescription : String = ""
  
  dynamic var setDescriptionFormatted : String = ""
  
  dynamic var summary : String = ""
  
  var imageURLs = List<Image>()
  
  
  
  /**
   Creates a Realm Movie object from the APISet
   */
  static func initMovie (from api : APISet) -> Movie {
    
    let images = List<Image>()
    for thisImageURL in api.imageURLs {
      let newImage = Image()
      newImage.url = thisImageURL
      images.append(newImage)
    }
    
    let movie = Movie()
    movie.uid = api.uid
    movie.title = api.title
    movie.setDescription = api.setDescription
    movie.setDescriptionFormatted = api.setDescriptionFormatted
    movie.summary = api.summary
    movie.imageURLs = images
    
    return movie
  }
  
}

/**
 The Images Object for each Realm Movie
 */
class Image : Object {
  
  dynamic var url : String = ""
}
