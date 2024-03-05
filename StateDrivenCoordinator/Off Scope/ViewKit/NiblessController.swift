//  Created by Roman Suvorov (kikiwora)

import UIKit
import OSLog

class NiblessController: UIViewController {
  init() {
    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.accessibilityIdentifier = "\(className)"
    Logger.viewLifeCycle.debug("\(self.classNameWithoutGeneric) didLoad") // swiftformat:disable redundantSelf
  }

  deinit {
    Logger.viewLifeCycle.debug("\(self.classNameWithoutGeneric) deinit") // swiftformat:disable redundantSelf
  }

  @available(*, unavailable, message: "Loading this view controller from a nib is unsupported in favour of initializer dependency injection.")
  required init?(coder aDecoder: NSCoder) {
    fatalError("Loading this view controller from a nib is unsupported in favour of initializer dependency injection.")
  }
}
