//  Created by Roman Suvorov (kikiwora)

import UIKit
import OSLog
import Convenient_Operators

// MARK: - ProfileNavProtocol

protocol ProfileNavProtocol: AnyObject {
  // Template
}

// MARK: - ProfileController

class ProfileController: NiblessController {
  var navigation: ProfileNavProtocol?

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Profile"
    view.backgroundColor = .green
  }
}
