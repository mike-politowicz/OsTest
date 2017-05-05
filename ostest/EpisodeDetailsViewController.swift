//
//  EpisodeDetailsViewController.swift
//  ostest
//
//  Created by Michael Politowicz on 5/4/17.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import UIKit

/**
 Displays the details of an Episode
 */
class EpisodeDetailsViewController: UIViewController {

  /// Episode image view
  @IBOutlet weak var imgMain: UIImageView?
  
  /// Title label
  @IBOutlet weak var lblTitle: UILabel?
  
  /// Synopsis text view
  @IBOutlet weak var txtSynopsis: UITextView?
  
  /// Episode
  var episode: Episode? {
    didSet {
      configureView()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
  }

  /**
   Pops view controller when back button is pressed
   */
  @IBAction func btnBackPressed(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
  }
  
  /**
   Sets UI elements based on episode parameters
   */
  fileprivate func configureView() {
    lblTitle?.text = episode?.title ?? ""
    txtSynopsis?.text = episode?.synopsis ?? ""
    if let episode = episode, let urlString = episode.imageURLs.first?.url, let url = URL(string: urlString) {
      imgMain?.isHidden = false
      imgMain?.af_setImage(withURL: url)
    } else {
      imgMain?.isHidden = true
    }
  }
  
}
