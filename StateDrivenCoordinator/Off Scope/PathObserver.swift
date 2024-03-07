//  Created by Roman Suvorov (kikiwora)

import UIKit
import OSLog

// MARK: - Events Listeners

extension Notification.Name {
  static let didChangePath = Notification.Name("didChangePath")
}

extension SceneDelegate {
  func addPathUpdateObserver() {
    NotificationCenter.default.addObserver(self, selector: #selector(handleNavigationPathChange), name: .didChangePath, object: nil)
  }

  @objc func handleNavigationPathChange() {
    // swiftlint:disable:next force_unwrapping
    Logger.navigation.info("Path Changed: 📁 \(self.mainFlow!.path.asString())") // swiftformat:disable: redundantSelf
  }
}

// MARK: - GlobalNavigation for MainFlow

extension MainFlow: GlobalNavigation {
  func goToSEVDetailsSub2() {
    let path: FlowPath = .make(from: "scores / sev / details / tab2 / microTab2")
    navigate(by: path)
  }
}
