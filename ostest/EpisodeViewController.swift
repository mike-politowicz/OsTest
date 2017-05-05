//
//  EpisodeViewController.swift
//  
//
//  Created by Michael Politowicz on 5/4/17.
//
//

import Foundation
import AlamofireImage
import RealmSwift
import SwiftyBeaver

/**
 Shows the list of Sets
 */
final class EpisodeViewController : UIViewController {
  
  /// Table View
  @IBOutlet private weak var tblView : UITableView?
  
  /// Activity loader for the table view
  @IBOutlet private weak var activity : UIActivityIndicatorView?
  
  /// Log
  let log = SwiftyBeaver.self
  
  /// The episode data
  fileprivate var data : Results<Episode>?
  
  /// The notification token for changes to the data objects
  fileprivate var notifications: NotificationToken?
  
  /**
   Setup the view
   */
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /// Setup view for loading
    self.setupLoading(isLoading: true)
    
    /// Call to setup the data
    self.setupData()
  }
  
  /**
   Setup loading
   
   - parameter isLoading
   */
  func setupLoading (isLoading : Bool) {
    self.activity?.startAnimating()
    UIView.animate(withDuration: 0.3, delay: 0.0, options: .beginFromCurrentState, animations: {
      self.activity?.alpha = isLoading ? 1.0 : 0.0
      self.tblView?.alpha = isLoading ? 0.0 : 1.0
    }) { (_) in
      if !isLoading {
        self.activity?.stopAnimating()
      }
    }
  }
  
  
  /**
   Sets up the data for the table view
   */
  func setupData () {
    Database.instance.fetchSets() { _ in
      Database.instance.fetchEpisodes(setTitle: "Home") { (episodes) in
        self.setupLoading(isLoading: false)
        
        self.data = episodes
        self.notifications = self.data?.addNotificationBlock {[weak self] changes in
          guard let tblView = self?.tblView else {
            return
          }
          switch changes {
          case .initial:
            self?.log.verbose("Initial run of DB episode query")
            tblView.reloadData()
          case .update(let results, let deletions, let insertions, let modifications):
            self?.log.verbose("Change to DB objects in episode query")
            tblView.beginUpdates()
            tblView.insertRows(at: insertions.map {IndexPath(row: $0, section: 0)}, with: .automatic)
            tblView.deleteRows(at: deletions.map {IndexPath(row: $0, section: 0)}, with: .automatic)
            for row in modifications {
              let indexPath = IndexPath(row: row, section: 0)
              if let cell = tblView.cellForRow(at: indexPath) as? EpisodeViewCell {
                let episode = results[indexPath.row]
                cell.configureWith(episode: episode)
              }
            }
            tblView.endUpdates()
          default: break
          }
        }
        self.log.verbose("Episode count \(String(describing: episodes?.count))")
      }
    }
  }
}


/**
 Table View datasource
 */
extension EpisodeViewController : UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.data?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    /// Get the cell
    guard let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeViewCell.identifier) as? EpisodeViewCell else {
      return UITableViewCell()
    }
    
    /// Set the data
    if let data = self.data?[indexPath.row] {
      cell.configureWith(episode: data)
    }
    
    /// Return the cell
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    /// Default
    return 180.0
  }
  
}


/**
 Table view delegate
 */
extension EpisodeViewController : UITableViewDelegate {
  
}