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
  
  /// The title label
  @IBOutlet weak var lblTitle : UILabel?
  
  /// The text view to show the description
  @IBOutlet weak var txtDescription : UITextView?
  
  /// Favourite
  @IBOutlet weak var btnFavourite : UIButton?
  
  /// Episode
  fileprivate var imageURL: URL?
  
  func configureWith(episode: Episode) {
    lblTitle?.text = episode.title
    txtDescription?.text = episode.synopsis
    if let urlString = episode.imageURLs.first?.url,
      let url = URL(string: urlString) {
      imageURL = url
      imgBackground?.af_setImage(withURL: url, completion: { response in
        if let imageURL = response.request?.url, imageURL != self.imageURL {
          self.imgBackground?.image = nil
        }
      })
    } else {
      imageURL = nil
      imgBackground?.image = nil
    }
  }
  
}
