//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators

// MARK: - ScoresFlow.Factory

extension ScoresFlow {
  typealias FlowDecommissionHandler = (FlowID, Screen) -> Void

  enum Factory {
    static func makeFlow(
      by screen: Screen,
      withNavigation sharedNavigationController: UINavigationController,
      onDecommission: @escaping FlowDecommissionHandler
    ) -> AnyFlow {
      let newFlow: AnyFlow = {
        switch screen {
        case .details:
          SEVDetailsFlow(with: sharedNavigationController)
        default:
          fatalError("\(screen) is not represented by any Flow")
        }
      }()

      newFlow.onDecommission = { [id = newFlow.id] in
        onDecommission(id, screen)
      }

      return newFlow
    }

    static func makeModule(by screen: Screen, flow: AnyFlow) -> UIViewController {
      switch screen {
      case .scores:
        ScoresController() => { $0.navigation = (flow as! ScoresNavProtocol) }
      case .sev:
        SEVController() => { $0.navigation = (flow as! SEVControllerNavProtocol) }
      case .details:
        fatalError("\(screen) is not represented by any Module")
      }
    }
  }
}
