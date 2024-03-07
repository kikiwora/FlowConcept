//  Created by Roman Suvorov (kikiwora)

import UIKit
import Convenient_Operators

extension SEVDetailsFlow {
  typealias FlowDecommissionHandler = (FlowID, Screen) -> Void

  enum Factory {
    static func makeFlow(
      by screen: Screen,
      onDecommission: @escaping FlowDecommissionHandler
    ) -> AnyFlow {
      let newFlow: AnyFlow = {
        switch screen {
        case .tab2:
          SEVSubDetailsFlow(with: UINavigationController())

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
      case .tab1: UIViewController() => {
          $0.view.backgroundColor = .red
          $0.addLabel("Tab 1")
        }

      case .tab3: UIViewController() => {
          $0.view.backgroundColor = .red
          $0.addLabel("Tab 3")
        }

      default:
        fatalError("\(screen) is not represented by any Module")
      }
    }
  }
}
