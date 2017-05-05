//
//  EpisodeDetailsViewController.swift
//  ostest
//
//  Created by Michael Politowicz on 5/4/17.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import UIKit

class EpisodeDetailsViewController: UIViewController {

  @IBOutlet weak var imgMain: UIImageView?
  @IBOutlet weak var lblTitle: UILabel?
  @IBOutlet weak var txtSynopsis: UITextView?
  
  var episode: Episode? {
    didSet {
      configureView()
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configureView()
  }

  @IBAction func btnBackPressed(_ sender: UIButton) {
    self.navigationController?.popViewController(animated: true)
  }
  
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
