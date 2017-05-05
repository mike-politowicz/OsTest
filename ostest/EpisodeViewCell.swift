//
//  EpisodeViewCell.swift
//  ostest
//
//  Created by Maninder Soor on 28/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import UIKit

/** 
  The episode view cell that shows an episode on the home screen
 */
class EpisodeViewCell : UITableViewCell {
  
  /// Reuse identifier
  static let identifier = "EpisodeViewCellIdentifier"
  
  /// Image view for the background
  @IBOutlet weak var imgBackground : UIImageView?
  
  /// Filter to darken background image
  @IBOutlet weak var viewImageFilter: UIView?
  
  /// The title label
  @IBOutlet weak var lblTitle : UILabel?
  
  /// The description label
  @IBOutlet weak var lblDescription: UILabel?
  
  /// Favourite
  @IBOutlet weak var btnFavourite : UIButton?
  
  /// Episode
  fileprivate var episode: Episode?
  
  // Image URL
  fileprivate var imageURLString: String = ""
  
  /**
   Sets UI elements based on episode parameters
   */
  func configureWith(episode: Episode) {
    self.episode = episode
    lblTitle?.text = episode.title
    lblDescription?.text = episode.synopsis
    btnFavourite?.setImage(episode.isFavourite ? #imageLiteral(resourceName: "heart_red") : #imageLiteral(resourceName: "heart_grey"), for: .normal)
    let urlString = episode.imageURLs.first?.url ?? ""
    guard urlString != imageURLString else {
      return
    }
    if let urlString = episode.imageURLs.first?.url, let url = URL(string: urlString) {
      self.imageURLString = urlString
      self.imgBackground?.isHidden = false
      self.viewImageFilter?.isHidden = false
      imgBackground?.af_setImage(withURL: url)
    } else {
      self.imageURLString = ""
      imgBackground?.isHidden = true
      viewImageFilter?.isHidden = true
    }
  }
  
  /**
   Sets favourite value for episode and updates UI
   */
  @IBAction func btnFavouritePressed(_ sender: UIButton) {
    if let episode = episode {
      Database.instance.changeFavouriteFor(episode: episode, isFavourite: !episode.isFavourite)
      btnFavourite?.setImage(episode.isFavourite ? #imageLiteral(resourceName: "heart_red") : #imageLiteral(resourceName: "heart_grey"), for: .normal)
    }
  }
  
  
}
