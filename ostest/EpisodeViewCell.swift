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
  
  
  func configureWith(episode: Episode) {
    lblTitle?.text = episode.title
    lblDescription?.text = episode.synopsis
    if let urlString = episode.imageURLs.first?.url, let url = URL(string: urlString) {
      self.imgBackground?.isHidden = false
      self.viewImageFilter?.isHidden = false
      imgBackground?.af_setImage(withURL: url)
    } else {
      imgBackground?.isHidden = true
      viewImageFilter?.isHidden = true
    }
  }
  
  @IBAction func btnFavouritePressed(_ sender: UIButton) {
    //btnFavourite?.setImage(#imageLiteral(resourceName: "heart_red"), for: .normal)
  }
  
  
}
