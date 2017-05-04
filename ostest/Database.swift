//
//  Database.swift
//  ostest
//
//  Created by Maninder Soor on 28/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyBeaver

/**
 The Database class manages DB access including convenint methods for inserts, deletions and updates
 */
class Database {
  
  /// Static Singleton
  static let instance = Database()
  
  /// Log
  let log = SwiftyBeaver.self
  
  /**
   The default realm
   */
  func defaultRealm () -> Realm? {
    do {
      return try Realm()
    } catch {
      log.error("The default realm couldn't be setup")
      return nil
    }
  }
  
  /**
   Fetch sets from the API server
   */
  func fetchSets (completion : @escaping (_ movies : Results<Movie>?) -> Void) {
    log.verbose("DB Updating sets")
    
    let fetchComplete = "FetchComplete"
    if UserDefaults.standard.object(forKey: fetchComplete) != nil {
      log.debug("DB already fetched API objects")
      completion(self.fetchMovies(sorted: true))
      return
    }
    
    /// Update the database
    API.instance.getSets { (isComplete, sets) in
      self.log.verbose("DB Updated sets with completion outcome \(isComplete)")
      
      /// Check for the error
      if isComplete == false {
        self.log.error("There was an error updating the DB with results form the API")
        return
      }
      
      /// Guard sets
      guard let apiSets = sets else {
        self.log.error("DB found the API set objects as nil")
        return
      }
      
      /// Convert API objects to Realm Objects
      let movies : [Movie] = apiSets.map({ Movie.initMovie(from: $0) })
      
      /// Set User Defaults
      UserDefaults.standard.set("Yes", forKey: fetchComplete)
      UserDefaults.standard.synchronize()
      
      /// Default
      completion(self.fetchMovies(sorted: true))
    }
    
  }
  
  /**
   Fetch from the default Realm
   */
  func fetchMovies(sorted sort : Bool) -> Results<Movie>? {
    
    var movies = self.defaultRealm()?.objects(Movie.self)
    
    if sort {
      movies = movies?.sorted(byKeyPath: "title")
    }
    
    /// Default
    return movies
  }
  
  /**
   Save the default Realm
   */
  func saveRealm (save objects : [Object]) -> Bool {
    
    do {
      try self.defaultRealm()?.write {
        for thisObject in objects {
          self.defaultRealm()?.add(thisObject)
        }
        self.log.verbose("Realm added objects")
      }
    } catch {
      return false
    }
    
    return false
  }
  
}
