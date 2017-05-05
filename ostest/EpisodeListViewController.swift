//
//  EpisodeListViewController.swift
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
 Shows the list of Episodes
 */
final class EpisodeListViewController : UIViewController {
  
  /// Table View
  @IBOutlet private weak var tblView : UITableView?
  
  /// Activity loader for the table view
  @IBOutlet private weak var activity : UIActivityIndicatorView?
  
  /// Pull-to-refresh control
  fileprivate var refreshControl = UIRefreshControl()
  
  /// Log
  fileprivate let log = SwiftyBeaver.self
  
  /// The episode data
  fileprivate var data : Results<Episode>?
  
  /// The notification token for changes to the data objects
  fileprivate var notifications: NotificationToken?
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /// Setup pull-to-refresh
    refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
    refreshControl.addTarget(self, action: #selector(refreshEpisodes), for: .valueChanged)
    self.tblView?.addSubview(refreshControl)
    
    /// Setup view for loading
    self.tblView?.alpha = 0.0
    self.setupLoading(isLoading: true)
    
    /// Call to setup the data
    self.setupData()
  }
  
  /**
   Setup loading
   - parameter isLoading
   */
  fileprivate func setupLoading (isLoading : Bool) {
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
  fileprivate func setupData () {
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
  
  /**
   Fetches new remote data
   */
  func refreshEpisodes() {
    Database.instance.fetchSets() { _ in
      Database.instance.fetchEpisodes(setTitle: "Home") { _ in
        self.refreshControl.endRefreshing()
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if let episodeDetailsVC = segue.destination as? EpisodeDetailsViewController,
      let selectedIndex = tblView?.indexPathForSelectedRow?.row {
      episodeDetailsVC.episode = data?[selectedIndex]
    }
  }
}


// MARK: - UITableViewDataSource

extension EpisodeListViewController : UITableViewDataSource {
  
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
    return 180.0
  }
  
}

// MARK: - UITableViewDelegate

extension EpisodeListViewController : UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.performSegue(withIdentifier: "segueShowEpisodeDetails", sender: self)
    tableView.deselectRow(at: indexPath, animated: true)
  }
  
}
