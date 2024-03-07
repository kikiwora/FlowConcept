//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators

// MARK: - ProfileFlow.Factory

extension ProfileFlow {
  enum Factory {
    static func makeModule(by screen: Screen, flow: AnyFlow) -> UIViewController {
      switch screen {
      case .profile: Factory.makeProfileModule(flow: flow as! ProfileNavProtocol)
      }
    }

    static func makeProfileModule(flow: ProfileNavProtocol) -> UIViewController {
      ProfileController() => { $0.navigation = flow }
    }
  }
}
