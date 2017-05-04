//
//  SetViewCell.swift
//  ostest
//
//  Created by Maninder Soor on 28/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import UIKit

/** 
  The set view cell that shows a movie on the home screen
 */
class SetViewCell : UITableViewCell {
  
  /// Reuse identifier
  static let identifier = "SetViewCellIdentifier"
  
  /// Image view for the background
  @IBOutlet weak var imgBackground : UIImageView?
  
  /// The title label
  @IBOutlet weak var lblTitle : UILabel?
  
  /// The text view to show the description
  @IBOutlet weak var txtDescription : UITextView?
  
  /// Favourite
  @IBOutlet weak var btnFavourite : UIButton?

  
}
