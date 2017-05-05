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
  fileprivate let log = SwiftyBeaver.self
  
  /**
   The default realm
   */
  fileprivate func defaultRealm () -> Realm? {
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
    let fetchCompleteKey = "FetchComplete"
    let fetchComplete = UserDefaults.standard.bool(forKey: fetchCompleteKey)
    
    if fetchComplete {
      log.debug("DB already fetched API set objects")
      completion(self.fetchMovies(sorted: true))
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
      guard self.saveRealm(save: movies) else {
        self.log.error("Unable to save objects to default Realm")
        return
      }
      
      if !fetchComplete {
        /// Set User Defaults
        UserDefaults.standard.set(true, forKey: fetchCompleteKey)
        
        /// Default
        completion(self.fetchMovies(sorted: true))
      }
      
    }
    
  }
  
  /**
   Fetch episodes from the API server
   */
  func fetchEpisodes (setTitle: String, completion : @escaping (_ episodes : Results<Episode>?) -> Void) {
    log.verbose("DB Updating episodes")
    
    guard let movie = fetchMovies(sorted: true)?.filter("title == '\(setTitle)'").first else {
      self.log.error("DB could not find \"\(setTitle)\" movie object")
      return
    }
    
    let fetchCompleteKey = "FetchComplete-\(setTitle)"
    let fetchComplete = UserDefaults.standard.bool(forKey: fetchCompleteKey)
    
    if fetchComplete {
      log.debug("DB already fetched API episode objects for '\(setTitle)' set")
      completion(self.fetchRealmEpisodes(sorted: true))
    }
    
    /// Update the database
    API.instance.getEpisodes(setUID: movie.uid) { (isComplete, episodes) in
      self.log.verbose("DB Updated episodes with completion outcome \(isComplete)")
      
      /// Check for the error
      if isComplete == false {
        self.log.error("There was an error updating the DB with results from the API")
        return
      }
      
      /// Guard episodes
      guard let apiEpisodes = episodes else {
        self.log.error("DB found the API episode objects as nil")
        return
      }
      
      /// Convert API objects to Realm Objects
      let realmEpisodes : [Episode] = apiEpisodes.map({ Episode.initEpisode(from: $0) })
      guard self.saveRealm(save: realmEpisodes) else {
        self.log.error("Unable to save objects to default Realm")
        return
      }
      
      if !fetchComplete {
        /// Set User Defaults
        UserDefaults.standard.set(true, forKey: fetchCompleteKey)
        
        /// Default
        completion(self.fetchRealmEpisodes(sorted: true))
      }
      
    }
    
  }
  
  /**
   Set favourite value for episode
   */
  func changeFavouriteFor(episode: Episode, isFavourite: Bool) {
    let realm = self.defaultRealm()
    do {
      try realm?.write {
        episode.isFavourite = isFavourite
        self.log.verbose("Realm episode favourite value updated")
      }
    } catch {
      self.log.error("Realm unable to update episode favourite value")
      return
    }
  }
  
  /**
   Fetch from the default Realm
   */
  fileprivate func fetchMovies(sorted sort : Bool) -> Results<Movie>? {
    
    var movies = self.defaultRealm()?.objects(Movie.self)
    
    if sort {
      movies = movies?.sorted(byKeyPath: "title")
    }
    
    /// Default
    return movies
  }
  
  /**
   Fetch from the default Realm
   */
  func fetchRealmEpisodes(sorted sort : Bool) -> Results<Episode>? {
    
    var episodes = self.defaultRealm()?.objects(Episode.self)
    
    if sort {
      episodes = episodes?.sorted(byKeyPath: "position")
    }
    
    /// Default
    return episodes
  }
  
  /**
   Save the default Realm movies
   */
  fileprivate func saveRealm (save movies : [Movie]) -> Bool {
    let realm = self.defaultRealm()
    do {
      try realm?.write {
        if let oldMovies = realm?.objects(Movie.self) {
          realm?.delete(oldMovies)
        }
        for movie in movies {
          realm?.add(movie, update: true)
        }
        self.log.verbose("Realm added / updated objects")
      }
    } catch {
      return false
    }
    return true
  }
  
  /**
   Save the default Realm episodes
   */
  fileprivate func saveRealm (save episodes : [Episode]) -> Bool {
    let realm = self.defaultRealm()
    do {
      try realm?.write {
        let newEpisodeUIDs = episodes.map() { $0.uid }
        if let oldEpisodes = realm?.objects(Episode.self) {
          for oldEpisode in oldEpisodes {
            if !newEpisodeUIDs.contains(oldEpisode.uid) {
              realm?.delete(oldEpisode)
            }
          }
        }
        for episode in episodes {
          if let oldEpisode = realm?.object(ofType: Episode.self, forPrimaryKey: episode.uid) {
            episode.isFavourite = oldEpisode.isFavourite
          }
          realm?.add(episode, update: true)
        }
        self.log.verbose("Realm added / updated objects")
      }
    } catch {
      return false
    }
    
    return true
  }
  
}
