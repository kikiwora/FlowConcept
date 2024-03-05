//  Created by Roman Suvorov (kikiwora)

import UIKit
import OSLog
import Convenient_Operators

// MARK: - FavouritesNavProtocol

protocol FavouritesNavProtocol: AnyObject {
  // Template
}

// MARK: - FavouritesController

class FavouritesController: NiblessController {
  var navigation: FavouritesNavProtocol?

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Favourites"
    view.backgroundColor = .yellow
  }
}
