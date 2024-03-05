//  Created by Roman Suvorov (kikiwora)

import UIKit

extension SceneDelegate {
  var shared: SceneDelegate? {
    UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
  }

  var sharedMainFlow: MainFlow? { shared?.mainFlow }
}
